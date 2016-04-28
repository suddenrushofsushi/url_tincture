defmodule UrlTinctureTest do
  use ExUnit.Case
  doctest UrlTincture

  test "correctly identifies http urls" do
    http_urls = [
      {:ok,  0, "http://disney.com"},
      {:ok,  1, "https://www.github.com"},
      {:ok,  2, "https://github.com/craigwaterman/url_tincture"},
      {:ok,  3, "https://github.com/craigwaterman/skeevy/commit/023364df1bef1cdc6240ddc99cf24a9f023f1e2a"},
      {:ok,  4, "https://github.com/craigwaterman/skeevy/pulls?q=is%3Apr+is%3Aclosed"},
      {:ok,  5, "https://en.wikipedia.org/w/index.php?search=elixir+language&title=Special:Search&go=Go&searchToken=92ehklrxpqe5tzr5nocejtqqn"},
      {:ok,  6, "https://en.wikipedia.org/wiki/Elixir_(programming_language)"},
      {:ok,  7, "https://en.wikipedia.org/wiki/Elixir_(programming_language)#cite_note-elixirhome-5"},
      {:ok,  8, "http://www.bignewsabout.com/asbestos cancer law lawsuit mesothelioma settlement.php"},
      {:ok,  9, "http://wwv.i-have-no-idea-howto-internet.com:8567/MyBestFrontpageWebsite.htm"},
      {:ok, 10, "http://ko.wikipedia.org/wiki/%EC%9C%84%ED%82%A4%EB%B0%B1%EA%B3%BC%3a%EB%8C%80%EB%AC%B8"}
    ]
    http_check(http_urls, &UrlTincture.safe_parse/1)
  end

  test "correctly identifies non-http urls" do
    non_http_urls = [
      {:error, 0, "httpc://forgot_how_to_internet.com/oh-dear.html"},
      {:error, 1, "www.cnn.com"},
      {:error, 2, "ftp://www.example.com"},
      {:error, 3, "ftp://thisisnotaurl"},
      {:error, 4, "bbq://also_not_a_url"}
    ]
    http_check(non_http_urls, &UrlTincture.safe_parse/1)
  end

  test "idenfities httpish urls" do
    assert UrlTincture.httpish?("http://github.com")
    assert UrlTincture.httpish?("https://github.com")
    refute UrlTincture.httpish?("Https://github.com")
    refute UrlTincture.httpish?("hTTp://github.com")
  end

  test "identifies non-httpish urls" do
    refute UrlTincture.httpish?("github.com")
    refute UrlTincture.httpish?("htt://github.com")
    refute UrlTincture.httpish?("ftp://place.com")
  end

  test "forces http protocol" do
    assert(UrlTincture.force_http("github.com") == "http://github.com")
    assert(UrlTincture.force_http("https://github.com") == "https://github.com")
  end

  test "canonicalizes with expected i/o (forcing http)" do
    canon_urls = [
      {"http://example.com",   1, "http://www.example.com"},
      {"http://example.com",   2, " example.com /"},
      {"http://example.com",   3, "example.COM"},
      {"https://example.com",  4, "https://example.com"},
      {"https://example.com", 5, "https://www.example.com:443/"},
      {"https://cryptocloud.ca:8082/search/get%20real%27", 6, "https://cryptocloud.ca:8082/search/get%20real%27/"},
      {"https://cryptocloud.ca:8082/search/get%20real%27", 7, "https://www.cryptocloud.ca:8082/search/get%20real%27/"},
      {"http://hbp-maste-appelast-q1brmrc61zc9-2006824672.us-east-1.elb.amazonaws.com/2011/07/why-spotify-will-kill-itunes", 8,
       "http://hbp-maste-appelast-q1brmrc61zc9-2006824672.us-east-1.elb.amazonaws.com/2011/07/why-spotify-will-kill-itunes"},
      {"http://yellowbirdsdonthavewingsbuttheyflytomakeyouexperiencea3dreality.com/news/2015/04/jan-boelo-360o-live-in-vr", 9,
       "http://www.yellowbirdsdonthavewingsbuttheyflytomakeyouexperiencea3dreality.com/news/2015/04/jan-boelo-360o-live-in-vr/"},
      {"http://kastles.tumblr.com", 10, "http://kastles.tumblr.com//"},
      {"http://linhumphrey.com", 11, "http://linhumphrey.com/#!"},
      {"http://universotokyo.com/2015/04/24/earth-day-tokyo-street-style-%e3%80%8c%e3%82%a2%e3%83%bc%e3%82%b9%e3%83%87%e3%82%a4%e6%9d%b1%e4%ba%ac-%e3%83%95%e3%82%a1%e3%83%83%e3%82%b7%e3%83%a7%e3%83%b3%e3%82%b9%e3%83%8a%e3%83%83%e3%83%97", 12,
       "http://universotokyo.com/2015/04/24/earth-day-tokyo-street-style-%e3%80%8c%e3%82%a2%e3%83%bc%e3%82%b9%e3%83%87%e3%82%a4%e6%9d%b1%e4%ba%ac-%e3%83%95%e3%82%a1%e3%83%83%e3%82%b7%e3%83%a7%e3%83%b3%e3%82%b9%e3%83%8a%e3%83%83%e3%83%97/"},
      {"http://finance.savesmart.com/savesmartas.103/search/web?ss=t&cid=132007436&ad.segment=savesmartas.103&ad.device=c&aid=0dab4f22-0f7c-4720-b7e3-932d947d0a2d&ridx=66&q=free%20credit%20report%20score&fpid=2&qlnk=true&insp=%3fpvaid%3d45d25b5c8ad14c7888ef6f", 13,
       "http://finance.savesmart.com/savesmartas.103/search/web?ss=t&cid=132007436&ad.segment=savesmartas.103&ad.device=c&aid=0dab4f22-0f7c-4720-b7e3-932d947d0a2d&ridx=66&q=Free%20Credit%20Report%20Score&fpid=2&qlnk=True&insp=%3Fpvaid%3D45d25b5c8ad14c7888ef6f#top"},
    ]
    for {expected, ordinal, url} <- canon_urls do
      result = UrlTincture.canonicalize_url(url)
      assert("#{expected}|#{ordinal}" == "#{result.canonical}|#{ordinal}")
    end
  end

  test "canonicalizes url and provides parent hash (for sub-page)" do
    result = UrlTincture.canonicalize_url("http://example.com/sample-test")
    assert(result == %UrlTincture.Info{canonical: "http://example.com/sample-test",
                     hash: "999E73A9EDA6C7F13C6B0272FE41A85518525478FDA98C1F173CC829D245F1A2",
                     parent_hash: "F0E6A6A97042A4F1F1C87F5F7D44315B2D852C2DF5C7991CC66241BF7072D1C4",
                     parent_canonical: "http://example.com",
                     original: "http://example.com/sample-test"})
  end

  test "canonicalizes url and provides parent hash (for root)" do
    result = UrlTincture.canonicalize_url("http://example.com/")
    assert(result == %UrlTincture.Info{canonical: "http://example.com",
                     hash: "F0E6A6A97042A4F1F1C87F5F7D44315B2D852C2DF5C7991CC66241BF7072D1C4",
                     parent_hash: "F0E6A6A97042A4F1F1C87F5F7D44315B2D852C2DF5C7991CC66241BF7072D1C4",
                     parent_canonical: "http://example.com",
                     original: "http://example.com/"})
  end

  test "canonicalized with expected i/o (not forcing http)" do
    error = {:error, "invalid url"}
    canon_urls = [
      {error, 1, " example.com "},
      {error, 2, "example.COM"},
      {error, 3, "example.com/example-path/"},
      {error, 4, "http://://www.eaglebendchiropractic.com"},
      {error, 5, "http://www./fire/links.htm"},
      {error, 6, "http://www./links.html"},
      {error, 7, "http:////www.baychiropracticcenter.com/"},
      {error, 8, "http://www./"},
      {error, 9, nil},
    ]
    for {expected, ordinal, url} <- canon_urls do
      result = UrlTincture.canonicalize_url(url, [force_http: false])
      assert("#{inspect(expected)}|#{ordinal}" == "#{inspect(result)}|#{ordinal}")
    end
  end

  test "normalizes http port and scheme" do
    http_normals = [
      { {"http", ""},       1, "http",  80 },
      { {"https", ""},      2, "http",  443},
      { {"https", ""},      3, "https", 443},
      { {"https", ":80"},   4, "https", 80},
      { {"http", ":8080"},  5, "http" , 8080},
      { {"http", ":9999"},  6, "http" , 9999},
      { {"https", ":9999"}, 7, "https" , 9999},
      { {"unknown", ":77"}, 8, "unknown" , 77},
    ]
    for {expected, ordinal, scheme, port} <- http_normals do
      assert("#{inspect expected}|#{ordinal}" == "#{inspect UrlTincture.normalized_http(scheme, port)}|#{ordinal}")
    end
  end

  test "removes www" do
    regular  = "http://www.example.com"
    queried  = "http://www.example.com/?url=http://www.example.com"
    assert(UrlTincture.remove_www(regular) == "http://example.com")
    assert(UrlTincture.remove_www(queried) == "http://example.com/?url=http://www.example.com")
  end

  test "can parse url safely" do
    error = {:error, "invalid url"}
    assert(UrlTincture.can_parse_safely?("http://") == error)
    assert(UrlTincture.can_parse_safely?("httpc://www.google.com") == error)
    assert(UrlTincture.can_parse_safely?("ftp://..") == error)
    assert(UrlTincture.can_parse_safely?("http://.") == {:ok, "http://."})
    assert(UrlTincture.can_parse_safely?("https://.") == {:ok, "https://."})
    assert(UrlTincture.can_parse_safely?("http://google.com") == {:ok, "http://google.com"})
    assert(UrlTincture.can_parse_safely?("https://google.com") == {:ok, "https://google.com"})
  end

  def http_check(urls, func) do
    for {expected, ordinal, url} <- urls do
      result = Tuple.to_list(func.(url)) |> Enum.at(0)
      assert("#{expected}|#{ordinal}" == "#{result}|#{ordinal}")
    end
  end

end
