defmodule KindleExtractor.Word do
  use Ecto.Schema
  import Ecto.Changeset

  alias KindleExtractor.Lookup

  @primary_key {:id, :string, autogenerate: false}
  schema "words" do
    field :word, :string
    field :stem, :string
    field :lang, :string

    has_many :lookups, Lookup, foreign_key: :word_key
  end

  def changeset(word, attrs) do
    word
    |> cast(attrs, [:word, :stem, :lang])
  end
end
