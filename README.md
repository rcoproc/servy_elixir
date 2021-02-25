# Servy

**TODO: Add description**

# Start Iex mix
iex -S mix

# To start Http Server
    spawn(fn() -> serve(client_socket) end)

    or

    spawn(Servy.HttpServer, :start, [4000])

# Call with curl

curl http://localhost:4000/bears

curl http://localhost:4000/hibernate/10000

curl http://localhost:4000/kaboom

curl http://localhost:4000/api/bears

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `servy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:servy, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/servy](https://hexdocs.pm/servy).

