defmodule MapReduce do

  def start() do
    files = [
      "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_01_processes.md",
      "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_02_mailbox.md",
      "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_03_link.md",
      "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_04_monitor.md",
      "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_05_map_reduce.md"
    ]

    MapReduce.Reducer.start(files)
  end

  defmodule Reducer do
    def start(files) do
      spawn(Reducer, :run, [self(), files])
    end

    def run(parent, files) do
      IO.puts("Reducer #{inspect(self())} with parebt #{inspect(parent)} and #{length(files)}")
      mappers = Enum.map(files, fn(file) -> MapReduce.Mapper.start(file) end)
      IO.puts("mappers started #{inspect(mappers)}")
      state = {parent, mappers, []}
      loop(state)
    end

    def loop({parent, [], results}) do
      IO.puts("Reducer #{inspect(self())} got results #{inspect(results)}")
      result = Enum.sum(results)
      send(parent, {:result, self(), result})
    end

    def loop({parent, mappers, results}) do
      IO.puts("Reducer #{inspect(self())} are in loop with #{length(mappers)} mappers left")
      receive do
        {:result, mapper, result} ->
          IO.puts("Reducer #{inspect(self())} got result #{result} from mapper #{inspect(mapper)}")
          mappers = List.delete(mappers, mapper)
          results = [result | results]
          state = {parent, mappers, results}
          loop(state)
        unknown_msg ->
          IO.puts("Reducer #{inspect(self())} got unknown message #{inspect(unknown_msg)}")
        after
          1000 -> IO.puts("Reducer #{inspect(self())} got messages")
      end
    end
  end

  defmodule Mapper do
    def start(file) do
      spawn(Mapper, :run, [self(), file])
    end

    def run(parent, file) do
      IO.puts("Mapper #{inspect(self())} with parent #{inspect(parent)} and file #{file}")
      count = words_cound(file)
      send(parent, {:result, self(), count})
    end

    def words_cound(file) do
      {:ok, content} = File.read(file)
      String.split(content) |> length()
    end

  end

end


# Результат работы
#iex(3)> flush()
# {:result, #PID<0.134.0>, 3533}
# :ok
