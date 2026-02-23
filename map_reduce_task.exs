defmodule MapReduce do

  def start() do
    tree = {:reducer, [
      {:reducer, [
        {:mapper, "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_01_processes.md"},
        {:mapper, "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_02_mailbox.md"},
        {:mapper, "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_03_link.md"},
      ]},
      {:reducer, [
        {:mapper, "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_04_monitor.md"},
        {:mapper, "/home/damian/Elixir/Projects/elixir_course_2/lesson_01/01_05_map_reduce.md"}
      ]}
    ]}
    start_process(tree)
  end

  def start_process({:reducer, children}) do
    IO.puts("Process reducer with #{length(children)} child processes")
    results = Task.async_stream(children, &start_process/1)
    Enum.reduce(results, 0, fn({:ok, count}, acc) -> count + acc end)
  end

  def start_process({:mapper, file}) do
    IO.puts("Process mapper #{inspect(self())} with file #{file}")
    {:ok, content} = File.read(file)
    String.split(content) |> length()
  end
end
