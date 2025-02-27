defmodule KindleExtractor do
  import Ecto.Query, only: [from: 2]

  alias KindleExtractor.{BookInfo, Lookup, Word, Tree, Repo, Dictionary, Entry, Book}

  def start(_type, _args) do
    IO.puts("Initializing dictionary...")

    init()
    {:ok, self()}
  end

  def init(dictionary \\ "JMdict") do
    Repo.start_link()
    Tree.start_link()

    with {:ok, dict} <- Dictionary.load_dictionary(dictionary),
         :ok <- Dictionary.load_tree(dict) do
          IO.puts("dictionary (#{dictionary}) tree initialized")
          {:ok, "dictionary (#{dictionary}) tree initialized"}
         else
          err -> err
         end
  end

  def queryWords(lang \\ "ja") do
    query =
      from w in Word,
      where: w.lang == ^lang,
      select: %{
        word: %{word: w.word},
      }

    words = Repo.all(query)

    all_words = Enum.map(words, fn w -> w.word end)
    count = Enum.count(all_words)

    %{words: all_words, count: count}
  end

  def extractLookup(count \\ 10, lang \\ "ja") do
    query =
      from l in Lookup,
        join: b in BookInfo, on: l.book_key == b.id,
        join: w in Word, on: l.word_key == w.id,
        where: w.lang == ^lang,
        limit: ^count,
        select: %{
          word: w.word,
          usage: l.usage,
          book_title: b.title,
          book_authors: b.authors
        }

    words = Repo.all(query)

    words
    |> Task.async_stream(fn elem ->
      %Entry{
        word: elem.word,
        usage: String.trim(elem.usage),
        book: %Book{
          title: elem.book_title,
          authors: elem.book_authors
        },
        meaning: queryMeaning(elem.word)
      }
    end)
    |> Enum.map(fn {:ok, entry} -> entry end)
  end

  def queryLookup(count \\ 10) do
    query =
      from l in Lookup,
        limit: ^count,
        select: %{
          usage: l.usage,
        }

    Repo.all(query)
  end

  def queryBooks do
    query = from b in BookInfo, []

    res = Repo.all(query)

    Enum.map(res, fn w -> %Book{
      title: w.title,
      authors: w.authors
    } end)
  end

  def queryMeaning(word), do: Tree.search(word)
end
