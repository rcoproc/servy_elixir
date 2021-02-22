defmodule Servy.Handler do

  import Servy.Plugins
  import Servy.Parse
  import Servy.FileHandler

  alias Servy.Conv

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("pages", File.cwd!)

  @doc "Transforms the request into a response."
  def handle(request) do
    #conv = parse(request)
    #conv = route(conv)
    #format_response(conv)
    request 
      |> parse 
      |> rewrite_path
      |> log
      |> route 
      |> emojify
      |> track
      |> format_response
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %Conv{ conv | status: 200, resp_body: "Bears, Liöns, Tigers" }
  end

  #def route(conv, "GET",  "/bears") do
  def route(%Conv{method: "GET", path:  "/bears"} = conv) do
    %Conv{ conv | status: 200, resp_body: "Tedy, Smokey, Paddington" }
  end

  def route(%Conv{method: "GET", path:  "/bears" <> id } = conv) do
    %Conv{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%Conv{method: "POST", path:  "/bears"} = conv) do
    %Conv{ conv | status: 201, resp_body: "Created a #{conv.params["type"]} bear name #{conv.params["name"]}" }
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id } = conv) do
    %Conv{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end



  def route(%Conv{method: "GET", path:  "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

    #case File.read(file) do
    #  {:ok, content} ->
    #    %{ conv | status: 200, resp_body: content }
    #  {:error, :enoent} ->
    #    %{ conv | status: 404, resp_body: "File not found" }
    #  {:error, reason} ->
    #    %{ conv | status: 500, resp_body: "File error: #{reason}" }
    #end

  # Using a case expression:
  #def route(%{method: "GET", path: "/bears/new"} = conv) do
  #  pages_path = Path.expand("../../pages", __DIR__)
  #  file = Path.join(pages_path, "form.html")

  #  case File.read(file) do
  #    {:ok, content} ->
  #      %{ conv | status: 200, resp_body: content }

  #    {:error, :enoent} ->
  #      %{ conv | status: 404, resp_body: "File not found!"}

  #    {:error, reason } ->
  #      %{ conv | status: 500, resp_body: "File error: #{reason}"}
  #  end
  #end

  # Using multi-clause functions:

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def format_response(%Conv{} = conv) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

expected_response = """
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 20

Bears, Lions, Tigers
"""

response = Servy.Handler.handle(request)

IO.puts response


request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response


request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

name=Monky&type=Gray
"""

response = Servy.Handler.handle(request)

IO.puts response
