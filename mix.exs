defmodule FsmDiagram.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/MickeyOoh/fsm_diagram"

  def project do
    [
      app: :fsm_diagram,
      version: @version,
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [
          threshold: 90.0, 
          ignore_modules: [
            FsmSample1,
        ]
      ],
      description: description(), 
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),

    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/example"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FsmDiagram.Application, []}
    ]
  end
  
  defp deps do
    [
      {:ex_doc, "~> 0.35", only: [:dev,:docs], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    """
    Generate diagrams of State Machines in Elixir.
    """
  end

  defp dialyzer() do
    [
      plt_add_apps: [:mix, :ex_unit],
      plt_file: {:no_warn, "fsm_diagram.plt"}
    ]
  end

  defp docs() do
    [
      main: "FsmDiagram",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "README.md",
        "CHANGELOG.md",
      ],
      before_closing_body_tag: &before_closing_body_tag/1
    ]
  end
  defp before_closing_body_tag(:html) do
  """
  <script type="module">
    import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs";
    mermaid.initialize({ startOnLoad: true });
  </script>
  """
  end

  defp before_closing_body_tag(_), do: ""

  defp package() do
    [
      files: [
        "CHANGELOG.md",
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "test"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
