# UrlTincture [![Build Status](https://travis-ci.org/suddenrushofsushi/url_tincture.svg?branch=master)](https://travis-ci.org/suddenrushofsushi/url_tincture)

Sanity checks and canonicalization for HTTP(S) URLs.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add url_tincture to your list of dependencies in `mix.exs`:

        def deps do
          [{:url_tincture, "~> 1.0"}]
        end

  2. Ensure url_tincture is started before your application (Elixir < 1.4):

        def application do
          [applications: [:url_tincture]]
        end
