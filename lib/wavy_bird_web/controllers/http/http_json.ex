defmodule WavyBirdWeb.HttpJSON do

  def echo(%{conn: conn}) do
    conn |> get_context()
  end

  defp get_context(conn) do
    %{
      request_headers:
        conn
        |> Map.get(:req_headers)
        |> Enum.map(fn x ->
          %{elem(x, 0) => Tuple.to_list(x) |> List.last()}
        end)
        |> Enum.reduce(fn x, y -> Map.merge(x, y) end),
      query_parameters: Map.get(conn, :query_params),
      request_body: Map.get(conn, :req_body)
    }
  end
end
