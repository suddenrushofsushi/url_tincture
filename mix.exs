defmodule UrlTincture.Mixfile do
  use Mix.Project

  def project do
    [app: :url_tincture,
     description: description,
     package: package,
     version: "0.0.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
   [
     {:poison, "~> 2.0"},
     {:earmark, "~> 0.2", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}
  ]
  end

  defp description do
    """
    A package to reduce extended forms of URLs to a canonical reference
    """
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Craig Waterman"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/craigwaterman/url_tincture"}
    ]
  end

end
