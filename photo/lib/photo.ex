defmodule Photo do
  alias Photo.Image

  defmodule Image do
    #defstruct hex: nil, color: nil, grid: nil, pixel_map: nil
    defstruct [
      hex: nil,
      color: nil,
      grid: nil,
      pixel_map: nil
    ]
  end

  def main(input) do
    input
    |> hash_input
    |> define_color
    |> grid_build
    |> even_filter
    |> pixel_build
    |> drawing
    |> save(input)
  end

  defp save(image, name) do
    File.write("#{name}.png", image)
  end

  defp hash_input(input) do
    hex =
    :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Image{hex: hex}
  end

  defp define_color(%Image{hex: [r,g,b | _rest]} = image), do: %Image{image | color: {r,g,b}}

  defp grid_build(%Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror/1)
    |> List.flatten
    |> Enum.with_index

    %Image{image | grid: grid}
  end

  defp mirror([a,b | _] = row), do: row ++ [b,a]

  defp even_filter(%Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn {c, _} -> rem(c, 2) == 0 end)
    %Image{image | grid: grid}
  end

  defp pixel_build(%Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn {_, index} ->
      h = rem(index, 5) * 50
      v = div(index, 5) * 50
      top_left = {h, v}
      bot_right = {h + 50, v + 50}
      {top_left, bot_right}
    end)
    %Image{image | pixel_map: pixel_map}
  end

  defp drawing(%Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

end
