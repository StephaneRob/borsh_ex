defmodule BorshEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/StephaneRob/borsh_ex"
  @version "0.1.0"

  def project do
    [
      app: :borsh_ex,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27.3"}
    ]
  end

  defp package do
    [
      description: "Elixir implementation of Binary Object Representation Serializer for Hashing",
      maintainers: ["Stéphane Robino"],
      licenses: ["BSD-2-Clause"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  def docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end
end
