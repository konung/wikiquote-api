class Wikiquote
  require 'net/http'
  require 'nokogiri'
  require 'json'

  @@lang = "en"
  @@url = "https://#{@@lang}.wikiquote.org/w/api.php"

  # getTitle (String CelebrityName)
  # Get page id of a page which correspond to argv title.
  # Return an int or nil if an error occurs

  def self.getTitle(title)
    uri = URI(@@url)
    newTitle = title.split(' ').collect{ |elem| elem.capitalize }.join(' ')
    params = { format: "json", action: "query", titles: newTitle }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      res = JSON.parse(res.body)["query"]["pages"].first[0].to_i
      if res == -1
        puts "Cannot find result for the given title"
      else
        res
      end
    else
      puts "Oops, something went wrong"
    end
  end

  # getSectionForPage (Fixnum pageId)
  # Get the sections for the given page id
  # Return an hash like : {sectionId: sectionName, ...} or an empty hash if an error occurs

  def self.getSectionsForPage(pageId)
    uri = URI(@@url)
    params = { format: "json", action: "parse", pageid: pageId, prop: "sections" }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      hash = {}
      begin
        arr = JSON.parse(res.body)["parse"]["sections"]
        arr.each do |elem|
          hash[elem["number"]] = elem["anchor"]
        end
      rescue
        puts "Given pageid not found"
      end
      hash
    else
      puts "Oops, something went wrong"
    end
  end

  # getQuotesForSection (Fixnum pageId, Fixnum sectionId)
  # Get all quotes from given section id
  # Return an array of string. Each string is a quote

  def self.getQuotesForSection(pageId, sectionId)
    uri = URI(@@url)
    params = { format: "json", action: "parse", pageid: pageId, noimages: "", section: sectionId }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      page = Nokogiri::HTML(res.body)
      arr1 = page.css("ul li")
      arr2 = page.css("ul li ul li")
      short = arr1 + arr2 - (arr1 & arr2)
      long = arr1 + arr2
      short.collect{ |l| l.text }
    else
      puts "Oops, something went wrong"
    end
  end

  # getRandomQuote (String CelebrityName)
  # Get a random quote from give celebrity name
  # Return a string which is the randomly picked quote

  def self.getRandomQuote(title)

    begin
      pageId = self.getTitle(title)
      sections = self.getSectionsForPage(pageId)
      sectionId = sections.key("Quotes")
      quotes = self.getQuotesForSection(pageId, sectionId)
      if quotes.count == 0
        puts "No quote found"
      end
      res = quotes[rand(quotes.length)]
      res
    rescue
    end

  end

  # resetUrl
  # Used after a language change to reset url

  def self.resetUrl()
    @@url = "https://#{@@lang}.wikiquote.org/w/api.php"
  end

  # setLang
  # Change Wikiquote language

  def self.setLang(lang)
    success = true

    if lang.length == 2
      begin
        url = URI.parse("https://#{lang}.wikiquote.org/")
        req = Net::HTTP.new(url.host, url.port)
        res = req.request_head(url.path)
        success = false unless res.code != "404"
      rescue
        success = false
      end

      if success
        @@lang = lang
      else
        puts "This lang is not supported"
      end
    else
      puts "The lang in parameter must be a two letters string"
    end
    self.resetUrl()
  end

end