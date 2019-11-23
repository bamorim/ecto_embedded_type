defmodule EctoEmbeddedType.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_embedded_type,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.1"},
      {:jason, "~> 1.1"},
      # quality
      {:ex_check, "~> 0.11.0", only: :dev, runtime: false},
      {:credo, "~> 1.1", only: :dev, runtime: false},
      {:dialyxir, "1.0.0-rc.7", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false}
    ]
  end
end
