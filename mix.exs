defmodule Cqlx.Mixfile do
  use Mix.Project

  def project do
    [app: :cqlx,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: 	[
    					:logger,

    					:cqerl,
		                :uuid,
		                :semver,
		                :re2,

    					:hashex,
    					:randex
    				],
     mod: {Cqlx, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
		{:cqerl, github: "matehat/cqerl"},
	    #
	    # deps for cqerl
	    #
	    {:uuid, github: "okeuday/uuid", tag: "c2900b499ce9569f0da6ac462a1e82c7c03fd9f4", override: true},
	    {:semver, github: "nebularis/semver", tag: "c7d509f38298ec6594be4efdcd8a8f2322760039", override: true},

		{:hashex, github: "timCF/hashex"},
		{:randex, github: "timCF/randex"}
    ]
  end
end
