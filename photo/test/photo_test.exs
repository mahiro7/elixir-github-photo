defmodule PhotoTest do
  use ExUnit.Case
  doctest Photo

  test "greets the world" do
    assert Photo.hello() == :world
  end
end
