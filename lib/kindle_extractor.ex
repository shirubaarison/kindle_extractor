defmodule KindleExtractor do
  import Ecto.Query, only: [from: 2]

  alias KindleExtractor.BookInfo
  alias KindleExtractor.Lookup
  alias KindleExtractor.Word
  alias KindleExtractor.Repo

  def hello do
    :world
  end

  def init do
    Repo.start_link()
  end

  def extractWords(lang \\ "en") do
    query = from w in Word,
            where: w.lang == ^lang,
            join: b in BookInfo, on: w.book_key == b.id

    words = Repo.all(query)

    Enum.map(words, fn w -> w.word end)
  end

  def extractLookup do
    query = from l in Lookup,
            join: b in BookInfo, on: l.book_key == b.id,
            join: w in Word, on: l.word_key == w.id,
            limit: 1

    words = Repo.all(query)
    |> Repo.preload(:word)
    |> Repo.preload(:book)

    Enum.map(words, fn elem -> {
      %{
        word: elem.word.word,
        usage: String.trim(elem.usage),
        book: %{
          title: elem.book.title,
          authors: elem.book.authors
        },
        meaning: "placeholder meaning bla bla"
      }
    } end)
  end

  def queryAllBooks() do
    query = from b in BookInfo, []

    res = Repo.all(query)

    Enum.map(res, fn w -> %{title: w.title, authors: w.authors} end)
  end
end
