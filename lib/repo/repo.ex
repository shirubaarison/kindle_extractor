defmodule KindleExtractor.Repo do
  use Ecto.Repo,
  otp_app: :kindle_extractor,
  adapter: Ecto.Adapters.SQLite3
end
