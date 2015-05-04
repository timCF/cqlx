defmodule Cqlx do
	use Application
	require Record
	Record.defrecord :cql_query, Record.extract(:cql_query, from_lib: "cqerl/include/cqerl.hrl")
	Record.defrecord :cql_result, Record.extract(:cql_result, from_lib: "cqerl/include/cqerl.hrl")
	@hosts :application.get_env(:cqlx, :hosts, nil) |> Enum.filter(fn({k,v}) -> is_list(k) and is_integer(v) end)
	defp random_host do
		[res|_] = Randex.shuffle(@hosts)
		res
	end
	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		{:ok, client} = :cqerl.new_client(random_host, [pool_min_size: 32, pool_max_size: 64])
		:cqerl.close_client(client)
		children = [
		# Define workers and child supervisors to be supervised
		# worker(Cqlx.Worker, [arg1, arg2, arg3])
		]

		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Cqlx.Supervisor]
		Supervisor.start_link(children, opts)
	end

	#
	#	public
	#
	def exec(q, args \\ []) when is_binary(q) and is_list(args) do
		{:ok, client} = :cqerl.new_client(random_host, [pool_min_size: 32, pool_max_size: 64])
		case :cqerl.run_query client, make_q(q, args) do
			{:ok, :void} -> 
				:cqerl.close_client(client)
				{:ok, :void}
			{:ok, ans = cql_result()}	->
				finres = case :cqerl.has_more_pages(ans) do
					false -> {:ok, ans |> :cqerl.all_rows |> Enum.map(&HashUtils.to_map/1)}
					true -> exec_proc(ans, ans |> :cqerl.all_rows |> Enum.map(&HashUtils.to_map/1))
				end
				:cqerl.close_client(client)
				finres
			error -> 		
				:cqerl.close_client(client)
				{:error, error}
		end
	end
	#
	#	public
	#


	defp exec_proc(ans, res) do
		{:ok, ans} = :cqerl.fetch_more(ans)
		case :cqerl.has_more_pages(ans) do
			false -> {:ok, (ans |> :cqerl.all_rows |> Enum.map(&HashUtils.to_map/1))++res }
			true -> exec_proc(ans, (ans |> :cqerl.all_rows |> Enum.map(&HashUtils.to_map/1))++res )
		end
	end

	defp make_q(q, args) do
		cql_query(
			consistency: 4,
			statement: q,
			values: args |> Enum.map(fn({k,v}) -> {k, maybe_transform_arg(v)} end),
			page_size: 100
		)		
	end
	defp maybe_transform_arg(str) when is_binary(str), do: :erlang.binary_to_list(str)
	defp maybe_transform_arg(map) when is_map(map), do: Enum.map(map, fn({k,v}) -> {k, maybe_transform_arg(v)} end)
	defp maybe_transform_arg(some), do: some

end
