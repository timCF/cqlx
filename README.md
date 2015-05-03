Cqlx
====

Cassandra simple client for elixir lang. To use it, add to config.exs file 

```
     config :cqlx,
     	hosts: [{'127.0.0.1', 9042}]
```

Next, use something like this

```
Cqlx.exec("INSERT INTO namespace.my_table (uuid, comment) VALUES (?,?);", [uuid: '3', comment: 'three'])
{:ok, :void}
Cqlx.exec("SELECT * FROM namespace.my_table WHERE (uuid = ?);", [uuid: '1'])
{:ok,
 [%{comment: "one", ids: :null, override: :null, status: :null, type: :null,
    uuid: "1"}]}
```

if something fails, &Cqlx.exec/2 will return {:error, error} term.