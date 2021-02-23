defmodule Servy.Parse do
  alias Servy.Conv

  def parse(request) do

    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    IO.inspect params_string
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{ method: method,
           headers: headers,
           params: params,
           path: path,
    }
  end

  @doc """
  Parses the given param string of the form 
  into a map with corresponding keys and values
  """
  def parse_params("application/x-www-form-urlencoded" <> _return, params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, params_string), do: %{}

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")

    headers = Map.put(headers, key, value)

    parse_headers(tail, headers)
  end
  def parse_headers([], headers), do: headers
end
