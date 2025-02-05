defmodule KindleExtractor do
  import Ecto.Query, only: [from: 2]

  alias KindleExtractor.BookInfo
  alias KindleExtractor.Lookup
  alias KindleExtractor.Word
  alias KindleExtractor.Repo
  alias KindleExtractor.Dictionary
  alias KindleExtractor.Entry
  alias KindleExtractor.Book

  def init(dictionary) do
    Repo.start_link()

    IO.inspect("Loading dictionary...")

    tree =
      dictionary
      |> Dictionary.load_dictionary()
      |> Dictionary.load_tree()

    tree
  end

  def extractWords(lang \\ "en") do
    query = from w in Word,
            where: w.lang == ^lang,
            join: b in BookInfo, on: w.book_key == b.id

    words = Repo.all(query)

    Enum.map(words, fn w -> w.word end)
  end

  def extractLookup(tree, count \\ 10) do
    query = from l in Lookup,
            join: b in BookInfo, on: l.book_key == b.id,
            join: w in Word, on: l.word_key == w.id,
            where: w.lang == "ja",
            limit: ^count

    words = Repo.all(query)
    |> Repo.preload(:word)
    |> Repo.preload(:book)

    Enum.map(words, fn elem -> {
      %Entry{
        word: elem.word.word,
        usage: String.trim(elem.usage),
        book: %Book{
          title: elem.book.title,
          authors: elem.book.authors
        },
        meaning: Dictionary.search(tree, elem.word.word)
      }
    } end)
  end

  def queryAllBooks() do
    query = from b in BookInfo, []

    res = Repo.all(query)

    Enum.map(res, fn w -> %{title: w.title, authors: w.authors} end)
  end

  def queryWord(tree, word) do
    Dictionary.search(tree, word)
  end
end
