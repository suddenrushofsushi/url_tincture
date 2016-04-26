defmodule UrlTincture do
  @moduledoc """
  The base module of UrlTincture.
  This module canonicalizes HTTP(S) urls.

  The primary methods provided are `canonicalize_url/1` & `canonicalize_url/2`
  """

  @error {:error, "invalid url"}

  defmodule Info do
    @moduledoc """
    A simple struct for returning canonicalization results.

    ## Contains:
    * `canonical`: The canonicalized URL
    * `hash`: A SHA-256 hash of the above
    * `original`: Returns the original URL

    ## Poison
    This struct derives `Poison.Encoder` from [poison](https://github.com/devinus/poison) for easy encoding
    """
    @derive [Poison.Encoder]
    defstruct canonical: "", hash: "", original: ""
  end

  @doc """
  Safely parses passed in URLs

  ## Parameters
    - `url`: The URL to parse

  ## Returns
  * `{:ok, %URI}` on success
  * `{:error, "invalid url"} on failure

  """
  def safe_parse(url) do
    case can_parse_safely?(url) do
      {:ok, url} ->
        case URI.parse(url) do
          %URI{scheme: nil} -> @error
          %URI{host: nil} -> @error
          parsed -> {:ok, parsed}
        end
      {:error, _} -> @error
    end
  end

  @doc """
  Test if passed url can be safely parsed

  ## Parameters
    - `url`: The URL to parse

  ## Returns
  * `{:ok, url}` on success
  * `{:error, "invalid url"}` on failure
  """
  def can_parse_safely?(url) do
    cond do
      String.contains?(url, ".") && httpish?(url) -> {:ok, url}
      true -> @error 
    end
  end

  @doc """
  Canonicalize a url, forcing scheme to be prepended when missing.

  URLs are:
  * Validated.
  * Downcased.
  * Stripped of www.
  * Stripped of fragments.
  * http(s) / 80(443) ports are normalized.

  ## Parameters
    - `url`: The URL to canonicalize

  ## Returns:
    * `%UrlTincture.Info{}` on success
    * `{:error, "error message"}` on failure

  """
  def canonicalize_url(url) do
    canonicalize_url(url, force_http: true)
  end

  @doc """
  Canonicalize a url, scheme not prepended when missing by default.

  See `UrlTincture.canonicalize_url/1` for details.

  ## Parameters
    - `url`: The URL to canonicalize
    - `opts`: Options to pass to the canonicalizer (currently only `force_http` is supported)

  ## TODO
  Replace the hardcoded crypto call with an atom
  """
  def canonicalize_url(url, opts) do
    opts = Keyword.merge([force_http: false], opts)

    parseable = cond do
      opts[:force_http] -> force_http(url)
      true -> url
    end

    result = parseable
              |> String.strip
              |> String.downcase
              |> remove_www
              |> safe_parse
    case result do
      {:ok, parsed} ->
        {scheme, port} = normalized_http(parsed.scheme, parsed.port)
        query = case parsed.query do
          nil -> ""
          _ -> "?" <> parsed.query
        end
        normalized_host = parsed.host |> String.strip
        normalized_path = (parsed.path || "") |> String.replace_trailing("/", "")
        normalized_url = scheme <> "://" <> normalized_host <> port <> normalized_path <> query
        hash = :crypto.hash(:sha256, normalized_url) |> Base.encode16
        %UrlTincture.Info{canonical: normalized_url, hash: hash, original: url}
      {:error, _} -> @error
    end
  end

  @doc """
  Normalizes http scheme/port combinations.

  Passes through any unrecognized combinations.

  ### Parameters
  * `scheme` - A string representing the URI parsed scheme
  * `port`   - An integer representing the URI parsed port

  ## Returns `{scheme, port}`
  * `(String) port` in the format ":num"

  """
  def normalized_http("http",  80),    do: {"http",  ""}
  def normalized_http("http",  443),   do: {"https", ""}
  def normalized_http("https", 443),   do: {"https", ""}
  def normalized_http(other, port),   do: {other, ":#{port}"}

  @doc """
  Detects if URLs are HTTP or HTTPS

  ## Parameters
  * `url` - The URL to analyze

  ## Returns
  * `boolean`
  """
  def httpish?(url) do
    url =~ ~r/http[s]{0,1}:\/\//
  end


  @doc """
  Removes the first www. from URLs

  ## Parameters
  * `url` - The URL to process

  ## Returns
  * `String` containing the processed URL
  """
  def remove_www(url) do
    Regex.replace(~r/(\/\/www\.)/, url, "//", [global: false])
  end

  @doc """
  Prepend http:// to urls as needed.

  ## Parameters
  * `url` - The URL to process

  ## Returns
  * `String` containing the processed URL
  """
  def force_http(url) do
    cond do
      httpish?(url) -> url
      true -> "http://" <> url
    end
  end

end
