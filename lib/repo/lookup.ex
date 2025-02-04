defmodule KindleExtractor.Lookup do
  use Ecto.Schema

  alias KindleExtractor.BookInfo
  alias KindleExtractor.Word

  @primary_key {:id, :string, autogenerate: false}
  schema "lookups" do
    field :usage, :string

    belongs_to :word, Word, foreign_key: :word_key, type: :string
    belongs_to :book, BookInfo, foreign_key: :book_key, type: :string

  end
end
