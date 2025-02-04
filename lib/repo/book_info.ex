defmodule KindleExtractor.BookInfo do
  use Ecto.Schema
  alias KindleExtractor.Lookup

  @primary_key {:id, :string, autogenerate: false}
  schema "book_info" do
    field :title, :string
    field :authors, :string
    field :lang, :string

    has_many :lookups, Lookup, foreign_key: :book_key
  end
end
