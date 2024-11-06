[like_amount, user_amount] = System.argv()

Mix.install([
  {:benchee, "~> 1.3"}, 
  {:postgrex, "~> 0.19"}, 
  {:ecto_sql, "~> 3.12"}
  #{:ecto, "~> 3.12"}
])

init = fn sql_file, postgres_opts -> 
  Ecto.Adapters.Postgres.storage_down(postgres_opts)
  Ecto.Adapters.Postgres.storage_up(postgres_opts)

  {:ok, db_conn} = Postgrex.start_link(postgres_opts)

  File.read!(sql_file)
  |> String.replace("LIKE_AMOUNT", like_amount) 
  |> String.replace("USER_AMOUNT", user_amount)
  # |> String.split([");\n\n", "$$;"]) 
  # |> Enum.map(fn part ->                  # Re-add delimiters conditionally
  #   cond do
  #     String.contains?(part, "DO $$") -> part <> "$$;"
  #     true -> part <> ");"
  #   end
  # end)
  |> String.split(";\n\n") 
  |> Enum.map(fn part -> part <> ";" end)
  |> Enum.each(fn sql ->
    IO.puts sql
    with {:error, e} <- Postgrex.query(db_conn, sql, [], timeout: 1_000_000) do
      IO.puts "Error: #{inspect e}"
      raise Postgrex.Error, message: "Could not prepare"
    end
    end)

  db_conn
end

postgres_opts = [
  password: System.get_env("POSTGRES_PASSWORD", "postgres"), 
  username: System.get_env("POSTGRES_USER", "postgres"),  
  pool_size: 10,
  queue_target: 50_000,
  queue_interval: 20_000,
  timeout: 20_000,
  connect_timeout: 20_000]

inheritance_conn = init.("inheritance_table.sql", Keyword.put(postgres_opts, :database, "inheritance"))
sti_conn = init.("sti.sql", Keyword.put(postgres_opts, :database, "sti"))
plain_conn = init.("plain.sql", Keyword.put(postgres_opts, :database, "plain_db"))
