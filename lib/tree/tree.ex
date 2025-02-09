defmodule KindleExtractor.Tree do
  use GenServer

  alias KindleExtractor.Tree
  alias KindleExtractor.Meaning

  defstruct value: nil, left: nil, right: nil, reading: nil, definition: nil

  # Client

  def start_link() do
    GenServer.start_link(Tree, nil, name: Tree)
  end

  def insert(value, reading, definition) do
    GenServer.call(Tree, {:insert, value, reading, definition})
  end

  def search(value) do
    GenServer.call(Tree, {:search, value})
  end

  def get do
    GenServer.call(Tree, :get_tree)
  end

  # Server (callbacks)

  @impl true
  def init(_elements), do: {:ok, nil}

  @impl true
  def handle_call({:insert, value, reading, definition}, _from, state) do
    new_state = insert(state, value, reading, definition)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:search, value}, _from, state) do
    case search(state, value) do
      {:error, _} = error -> {:reply, error, state}
      meaning -> {:reply, meaning, state}
    end
  end

  @impl true
  def handle_call(:get_tree, _from, state) do
    {:reply, state, state}
  end

  def insert(nil, value, reading, definition) do
    %Tree{value: value, reading: reading, definition: definition}
  end

  def insert(%Tree{value: root_value, left: left, right: right} = node, value, reading, definition) do
    cond do
      value < root_value -> %Tree{node | left: insert(left, value, reading, definition)}
      value > root_value -> %Tree{node | right: insert(right, value, reading, definition)}
      true -> node
    end
  end

  def search(nil, _value), do: {:error, "Word not found"}
  def search(%Tree{value: root_value, left: left, right: right,
              reading: reading, definition: definition}, value) do
    cond do
      value < root_value -> search(left, value)
      value > root_value -> search(right, value)
      true -> %Meaning{reading: reading, definition: transformDefinition(definition)}
    end
  end

  defp transformDefinition(definition) do
    definition
    |> Enum.flat_map(&String.split(&1, ~r/\s*\n\s*/, trim: true))
    |> Enum.with_index(1)
    |> Enum.map(fn {value, index} -> {index, value} end)
    |> Enum.into(%{})
  end
end
