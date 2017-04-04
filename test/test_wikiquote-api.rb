require 'minitest/autorun'
require 'wikiquote-api'

class WikiquoteTest < Minitest::Test

  def test_getTitle
    assert_nil Wikiquote.getTitle("kugqfgqiufd")
    assert_kind_of Fixnum, Wikiquote.getTitle("Bill Gates")
    assert_equal 105, Wikiquote.getTitle("Bill Gates")
  end

  def test_getSections
    assert_nil Wikiquote.getTitle("kugqfgqiufd")
    assert_equal Hash.new(), Wikiquote.getSectionsForPage(-1)
    assert_kind_of Hash, Wikiquote.getSectionsForPage(105)
  end

  def test_getQuoteForSection
    assert_kind_of Array, Wikiquote.getQuotesForSection(105, "")
    assert_empty Wikiquote.getQuotesForSection(105, "")
    assert_kind_of String, Wikiquote.getQuotesForSection(105, "1")[0]
  end

end