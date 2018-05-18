class Wikiquote
  require 'net/http'
  require 'nokogiri'
  require 'json'

  @@lang = "en"
  @@url = "https://#{@@lang}.wikiquote.org/w/api.php"

  # getTitle (String CelebrityName)
  # Get page id of a page which correspond to argv title.
  # Return a positive int or -1 if an error occurs

  def self.getTitle(title)
    uri = URI(@@url)
    new_title = title.split(' ').collect{ |elem| elem.capitalize }.join(' ')
    params = { format: "json", action: "query", titles: new_title }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      res = JSON.parse(res.body)["query"]["pages"].first[0].to_i
    else
      # puts "Request didn't succeed"
      res = -1
    end
    res
  end

  # getSectionForPage (Fixnum page_id)
  # Get the sections for the given page id
  # Return an hash like : {section_id: sectionName, ...} or an empty hash if an error occurs

  def self.getSectionsForPage(page_id)

    uri = URI(@@url)
    params = { format: "json", action: "parse", pageid: page_id, prop: "sections" }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    hash = {}
    if res.is_a?(Net::HTTPSuccess)
      unless page_id == -1
        arr = JSON.parse(res.body)["parse"]["sections"]
        arr.each do |elem|
          hash[elem["number"]] = elem["anchor"]
        end
        hash["title"]= JSON.parse(res.body)["parse"]["title"]
      end
    else
      # puts "Request didn't succeed"
    end
    hash
  end

  # getQuotesForSection (Fixnum page_id, Fixnum section_id)
  # Get all quotes from given section id
  # Return an array of string. Each string is a quote

  def self.getQuotesForSection(page_id, section_id)
    uri = URI(@@url)
    params = { format: "json", action: "parse", pageid: page_id, noimages: "", section: section_id }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    ret = []
    if res.is_a?(Net::HTTPSuccess)
      arr = JSON.parse(res.body)
      unless arr["error"]
        page = Nokogiri::HTML(arr["parse"]["text"]["*"])
        arr1 = page.css("ul li")
        arr2 = page.css("ul li ul li")
        short = arr1 + arr2 - (arr1 & arr2)
        long = arr1 + arr2
        ret = short.collect{ |l| l.text }
      end
    else
      # puts "Request didn't succeed"
    end
    ret
  end

  # getRandomQuote (String CelebrityName)
  # Get a random quote from give celebrity name
  # Return a string which is the randomly picked quote

  def self.getRandomQuote(title)

    res = ""
    begin
      page_id = self.getTitle(title)
      unless page_id == -1
        quotes = self.getQuotesForSection(page_id, 1)
        res = quotes[rand(quotes.length)]
      end
    rescue
    end
    res

  end

  # resetUrl
  # Used after a language change to reset url

  def self.resetUrl()
    @@url = "https://#{@@lang}.wikiquote.org/w/api.php"
  end

  # setLang
  # Change Wikiquote language
  # Return true if succeed or false if error

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
    success
  end

end
