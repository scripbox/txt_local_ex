defmodule TxtLocalEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :txt_local_ex,
      version: "0.1.3",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "An Elixir client for sending SMS with txtLocal APIs",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TxtLocalEx, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env in ~w(test dev)a, do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.2"},
      {:jason, "~> 1.1.0"},
      {:ex_rated, "~> 1.2"},
      {:mock, "~> 0.3.0", only: :test}
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
