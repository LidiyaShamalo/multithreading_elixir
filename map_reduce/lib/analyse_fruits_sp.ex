defmodule AnalyseFruitsSP do
  @moduledoc """
  Single process solution
  """

  @type result :: %{String.t() => integer}

  @spec start() :: result
  def start() do
    start([
      "./data/data_1.csv",
      "./data/data_2.csv",
      "./data/data_3.csv"
    ])
  end

  @spec start([String.t()]) :: result
  def start(files) do
    result =
      files
    |> Stream.flat_map(fn filename -> File.stream!(filename) end)
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, ",") end)
    |> Enum.map(fn [_id, name, count, _price] ->
      %{name: name, count: String.to_integer(count)}
    end)
    |> Enum.reduce(%{}, fn %{name: name, count: count}, acc ->
          Map.update(acc, name, count, fn existing_count ->
            existing_count + count end)
      end)
  end

end

# [
#   [
#     ["1", "apples", "100", "150"],
#     ["2", "tomatos", "20", "10"],
#     ["3", "potato", "17", "230"],
#     ["4", "tangerin", "289", "101"],
#     ["5", "ananas", "14", "23"]
#   ],
#   [
#     ["1", "melon", "332", "53"],
#     ["2", "cucumber", "12", "3"],
#     ["3", "tangerin", "23", "53"],
#     ["4", "pear", "52", "51"],
#     ["5", "apples", "120", "115"],
#     ["6", "potato", "77", "52"]
#   ],
#   [
#     ["1", "apples", "25", "15"],
#     ["2", "tangerin", "18", "51"],
#     ["3", "pear", "6", "55"]
#   ]
# ]
