defmodule ExS3Edit.MixProject do
  use Mix.Project

  @app :ex_s3_edit

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.12.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_env: [release: :prod],
      test_paths: ["test"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExS3Edit, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bakeware, runtime: false},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.18.0", only: :dev}
    ]
  end

  defp release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      quiet: true,
      steps: [:assemble, &Bakeware.assemble/1],
      strip_beams: [keep: ["Docs"]]
    ]
  end
end
