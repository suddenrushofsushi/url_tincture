defmodule UrlTincture do
  @moduledoc """
  The base module of UrlTincture.
  This module canonicalizes HTTP(S) urls.

  The primary methods provided are `canonicalize_url/1` & `canonicalize_url/2`
  """

  defmodule Info do
    defstruct canonical: "", hash: "", original: ""
  end

  @doc """
  Validate whether a string is an HTTP(S) url.

  Adapted from [github/jonotander/is_url](https://github.com/johnotander/is_url)
  which in turn was adapted from [Stack Overflow](http://stackoverflow.com/questions/30696761/check-if-a-url-is-valid-in-elixir).

  ## Parameters
    - `url`: The URL to validate

  ## Returns
  * `boolean`

  """
  def http_url?(url) do
    if String.contains?(url, ".") && httpish?(url) do
      case URI.parse(url) do
        %URI{scheme: nil} -> false
        %URI{host: nil, path: nil} -> false
        _ -> true
      end
    else
      false
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
    * `{:ok, "canonical_url", ":sha256 hash", "original_url"}` on success
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

    if http_url?(parseable) do
      parsed = parseable
                |> String.strip
                |> String.downcase
                |> remove_www
                |> URI.parse
      {scheme, port} = normalized_http(parsed.scheme, parsed.port)
      query = case parsed.query do
        nil -> ""
        _ -> "?" <> parsed.query
      end
      normalized_host = parsed.host |> String.strip
      normalized_url = scheme <> "://" <> normalized_host <> port <> (parsed.path || "") <> query
      hash = :crypto.hash(:sha256, normalized_url) |> Base.encode16
      %UrlTincture.Info{canonical: normalized_url, hash: hash, original: url}
    else
      {:error, "invalid url"}
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
    String.starts_with?(url, "http://") || String.starts_with?(url, "https://")
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
