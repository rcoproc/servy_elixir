defmodule ParserTest do
  use ExUnit.Case
  doctest Servy.Parse

  alias Servy.Parse

  test "parsers a list of header fields into a map" do
    header_lines = ["A: 1", "B: 2"]

    headers = Parse.parse_headers(header_lines, %{})

    assert headers == %{"A" => "1", "B" => "2"}
  end

end
