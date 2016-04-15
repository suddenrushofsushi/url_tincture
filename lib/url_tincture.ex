defmodule UrlTincture do
  @moduledoc """
  The base module of UrlTincture.
  This module canonicalizes HTTP(S) urls
  """

  @doc """
  Validate whether a string is an HTTP(S) url.
  Adapted from [github/jonotander/is_url](https://github.com/johnotander/is_url)
  which in turn was adapted from [Stack Overflow](http://stackoverflow.com/questions/30696761/check-if-a-url-is-valid-in-elixir).

  Args:
  * `url` - The url to validate, string
  Returns a boolean.
  """
  def is_http_url?(url) do
    if String.contains?(url, ".") && String.match?(url, ~r/^https?:\/\//) do
      case URI.parse(url) do
        %URI{scheme: nil} -> false
        %URI{host: nil, path: nil} -> false
        _ -> true
      end
    else
      false
    end
  end
end
