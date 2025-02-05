defmodule KindleExtractor do
  import Ecto.Query, only: [from: 2]

  alias KindleExtractor.{BookInfo, Lookup, Word, Repo, Dictionary, Entry, Book}

  def init(dictionary) do
    Repo.start_link()

    with {:ok, dictionary} <- Dictionary.load_dictionary(dictionary),
         {:ok, tree} <- Dictionary.load_tree(dictionary) do
          tree
         else
          err -> err
         end
  end

  def extractWords(lang \\ "en") do
    query = from w in Word,
            where: w.lang == ^lang,
            join: b in BookInfo, on: w.book_key == b.id

    words = Repo.all(query)

    Enum.map(words, fn w -> w.word end)
  end

  def extractLookup(tree, count \\ 10) do
    query =
      from l in Lookup,
        join: b in BookInfo, on: l.book_key == b.id,
        join: w in Word, on: l.word_key == w.id,
        where: w.lang == "ja",
        limit: ^count,
        select: %{
          word: w.word,
          usage: l.usage,
          book_title: b.title,
          book_authors: b.authors
        }

    words = Repo.all(query)

    Enum.map(words, fn elem -> {
      %Entry{
        word: elem.word,
        usage: String.trim(elem.usage),
        book: %Book{
          title: elem.book_title,
          authors: elem.book_authors
        },
        meaning: Dictionary.search(tree, elem.word)
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
