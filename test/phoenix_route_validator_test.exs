defmodule PhoenixRouteValidatorTest do
  use ExUnit.Case
  doctest PhoenixRouteValidator

  test "Should detect conflicting routes" do
    endpoints = [
      {"get", "manage/example/:example_id"},
      {"get", "manage/example/:example_id/edit"},
      {"get", "manage/example/:example_id/delete"},
      {"get", "manage/example/hello/delete"},
      {"get", "manage/:id"},
      {"get", "manage/hello"}
    ]

    assert PhoenixRouteValidator.find_conflicts(endpoints) == [
             {4, [{{"get", "manage/hello"}, 5}]}
           ]
  end
end
