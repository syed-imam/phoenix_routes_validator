defmodule Mix.Tasks.Validate.Routes do
  @shortdoc "Validates Phoenix routes for conflicts"

  @moduledoc false
  use Mix.Task

  @spec run(term()) :: :ok
  def run(args) do
    Mix.Task.run("app.start")

    router =
      case args do
        [router_module] ->
          Module.concat([router_module])

        _ ->
          Mix.shell().error(
            "Please provide a router module. Example:\n\n  mix validate.routes MyAppWeb.Router"
          )

          Mix.raise("Missing router module.")
      end

    if router && function_exported?(router, :__routes__, 0) do
      routes =
        Enum.map(router.__routes__(), fn route ->
          {route.verb, route.path}
        end)

      case PhoenixRouteValidator.find_conflicts(routes) do
        [] ->
          Mix.shell().info("✅ No conflicting routes found.")

        conflicts ->
          Mix.shell().error("❌ Conflicting routes detected:")

          Enum.each(conflicts, fn {index, matches} ->
            {method, path} = Enum.at(routes, index)
            Mix.shell().error("Route #{index}: #{method} #{path}")

            Enum.each(matches, fn {{conflict_method, conflict_path}, _} ->
              Mix.shell().error("  Conflicts with: #{conflict_method} #{conflict_path}")
            end)
          end)

          Mix.raise("Route validation failed!")
      end
    else
      Mix.shell().error("Phoenix router not found or routes unavailable.")
      Mix.raise("Validation aborted.")
    end

    :ok
  end
end
