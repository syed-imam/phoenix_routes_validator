defmodule PhoenixRouteValidator do
  @moduledoc """
  Documentation for `PhoenixRouteValidator`.
  """

  @doc """
  Take a list of routes and returns a list of conflicting routes
  """
  @spec find_conflicts(list()) :: list()
  def find_conflicts(routes) do
    map =
      routes
      |> Enum.with_index()
      |> Enum.filter(fn {{_, route}, _} -> String.contains?(route, ":") end)
      |> Enum.into(%{}, fn {route, index} ->
        {index, route}
      end)

    conflicts =
      Enum.map(map, fn {key, {dynamic_route_method, dynamic_route}} ->
        dynamic_route_segments = String.split(dynamic_route, "/")

        remaining_dynamic_route =
          find_dynamic_segment_indexes(dynamic_route_segments)
          |> delete_dynamic_parts(dynamic_route_segments)

        matched_routes =
          routes
          |> Enum.with_index()
          |> Enum.filter(fn {{method, route}, index} ->
            if index > key do
              route_segments = String.split(route, "/")

              if length(dynamic_route_segments) == length(route_segments) do
                remaining_route =
                  find_dynamic_segment_indexes(route_segments)
                  |> delete_dynamic_parts(route_segments)

                remaining_route =
                  if remaining_route == route_segments do
                    {_, rem} = List.pop_at(remaining_route, -1)
                    rem
                  else
                    remaining_route
                  end

                remaining_dynamic_route == remaining_route && method == dynamic_route_method
              end
            end
          end)

        {key, matched_routes}
      end)

    Enum.filter(conflicts, fn {_, matches} -> length(matches) > 0 end)
  end

  @spec find_dynamic_segment_indexes(list()) :: [integer()]
  def find_dynamic_segment_indexes(route_segments) do
    Enum.with_index(route_segments)
    |> Enum.filter(fn {segment, _} -> String.contains?(segment, ":") end)
    |> Enum.map(fn {_, index} -> index end)
  end

  @spec delete_dynamic_parts([integer()], list()) :: list()
  def delete_dynamic_parts(indexes_to_remove, route_segments) do
    route_segments
    |> Enum.with_index()
    |> Enum.reject(fn {_, index} -> index in indexes_to_remove end)
    |> Enum.map(fn {segment, _} ->
      segment
    end)
  end
end
