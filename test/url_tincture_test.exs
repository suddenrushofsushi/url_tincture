defmodule UrlTinctureTest do
  use ExUnit.Case
  doctest UrlTincture

  test "correctly identifies http urls" do
    http_urls = [
      { true,  0, "http://disney.com" },
      { true,  1, "https://www.github.com" },
      { true,  2, "https://github.com/craigwaterman/url_tincture" },
      { true,  3, "https://github.com/craigwaterman/skeevy/commit/023364df1bef1cdc6240ddc99cf24a9f023f1e2a" },
      { true,  4, "https://github.com/craigwaterman/skeevy/pulls?q=is%3Apr+is%3Aclosed" },
      { true,  5, "https://en.wikipedia.org/w/index.php?search=elixir+language&title=Special:Search&go=Go&searchToken=92ehklrxpqe5tzr5nocejtqqn" },
      { true,  6, "https://en.wikipedia.org/wiki/Elixir_(programming_language)" },
      { true,  7, "https://en.wikipedia.org/wiki/Elixir_(programming_language)#cite_note-elixirhome-5" },
      { true,  8, "http://www.bignewsabout.com/asbestos cancer law lawsuit mesothelioma settlement.php" },
      { true,  9, "http://wwv.i-have-no-idea-howto-internet.com:8567/MyBestFrontpageWebsite.htm" },
      { true, 10, "http://ko.wikipedia.org/wiki/%EC%9C%84%ED%82%A4%EB%B0%B1%EA%B3%BC%3a%EB%8C%80%EB%AC%B8" }
    ]
    test_urls(http_urls)
  end

  test "correctly identifies non-http urls" do
    non_http_urls = [
      { false, 0, "httpc://forgot_how_to_internet.com/oh-dear.html" },
      { false, 1, "www.cnn.com" },
      { false, 2, "ftp://www.example.com" },
      { false, 3, "ftp://thisisnotaurl" },
      { false, 4, "bbq://also_not_a_url" }
    ]
    test_urls(non_http_urls)
  end

  def test_urls(urls) do
    for {expected, ordinal, url} <- urls do
      assert("#{UrlTincture.is_http_url?(url)}/#{ordinal}" == "#{expected}/#{ordinal}")
    end
  end
end
