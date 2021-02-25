defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "accepts a request on a socket and sends back a response - port 4000" do
    spawn(HttpServer, :start, [4000])

    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = HttpClient.send_request(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 22\r
    \r\n
    Bears, Lions, Tigers\n
    """
  end

  test "accepts a request on a socket and sends back a response port 4001" do
    spawn(HttpServer, :start, [4001])

    {:ok, response} = HTTPoison.get "http://localhost:4001/wildthings"

    assert response.status_code == 200
    assert response.body == "\nBears, Lions, Tigers\n"
  end

end
