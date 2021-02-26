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

    #url = "http://localhost:4001/wildthings"
    urls = [
      "http://localhost:4001/wildthings",
      "http://localhost:4001/bears",
      "http://localhost:4001/bears/1",
      "http://localhost:4001/wildlife",
      "http://localhost:4001/api/bears"
    ]

    urls
    |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end


  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
    #assert response.body == "\nBears, Lions, Tigers\n"
  end

end
