defmodule Servy.Handler do

  import Servy.Plugins
  import Servy.Parse
  import Servy.FileHandler
  import Servy.View, only: [render: 3]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

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
      |> put_content_length
      |> format_response
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do
    # task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)
    # or
    task = Task.async(Servy.Tracker, :get_location, ["bigfoot"]) 

    snapshots = 
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    #%{ conv | status: 200, resp_body: inspect { snapshots, where_is_bigfoot} }
    render(conv, "sensors.eex", snapshots: snapshots, location: where_is_bigfoot)
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!" }
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %Conv{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  #def route(conv, "GET",  "/bears") do
  def route(%Conv{method: "GET", path:  "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path:  "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path:  "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path:  "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id } = conv) do
    BearController.delete(conv, conv.params)
  end


  def route(%Conv{method: "GET", path:  "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    @pages_path
      |> Path.join("#{name}.md")
      |> File.read
      |> handle_file(conv)
      |> markdown_to_html
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{ conv | resp_body: Earmark.as_html!(conv.resp_body) }
  end

  def markdown_to_html(%Conv{} = conv), do: conv

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

  #def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
  #  @pages_path
  #  |> Path.join("form.html")
  #  |> File.read
  #  |> handle_file(conv)
  #end

  def route(%Conv{path: path} = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{ conv | resp_headers: headers }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  # using Enum.map:

  defp format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn {key, value} ->
      "#{key}: #{value}\r"
    end) |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end

  # or using a comprehension:

  #defp format_response_headers(conv) do
  #  for {key, value} <- conv.resp_headers do
  #    "#{key}: #{value}\r"
  #  end |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  #end

end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

#expected_response = """
#HTTP/1.1 200 OK
#Content-Type: text/html
#Content-Length: 20

#Bears, Lions, Tigers
#"""

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

#request = """
#GET /bears/new HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*

#"""

#response = Servy.Handler.handle(request)

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded

name=Monky&type=Gray
"""

response = Servy.Handler.handle(request)

IO.puts response


request = """
GET /pages/faq HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
