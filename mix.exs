defmodule TxtLocalEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :txt_local_ex,
      version: "0.1.1",
      elixir: "~> 1.6",
      description: "An Elixir client for sending SMS with txtLocal APIs",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {TxtLocalEx, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.1"},
      {:poison, "~> 3.1"},
      {:ex_rated, "~> 1.2"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Scripbox"],
      links: %{"GitHub" => "https://github.com/scripbox/txt_local_ex"}
    ]
  end
end
