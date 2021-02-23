defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  @templates_path Path.expand("templates", File.cwd!)

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}" 
  end

  defp render(conv,template, bindings \\ []) do
    content = 
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)

    %Conv{ conv | status: 200, resp_body: content }
  end

  def index(conv) do
    #|> Enum.filter( &Bear.is_grizzly/1 )
    #|> Enum.sort( &Bear.order_asc_by_name/2 )
    bears = 
      Wildthings.list_bears()
        |>Enum.sort( &Bear.order_asc_by_name/2 )

    #render(conv, "index.eex", bears: bears )
    %{ conv | status: 200, resp_body: BearView.index(bears) }
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    #render(conv, "show.eex", bear: bear )
    %{ conv | status: 200, resp_body: BearView.show(bear) }
  end

  def create(conv, %{"name" => name, "type" => type} = params) do
    %Conv{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}!" }
  end

  def delete(conv, _params) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

end
