import Config

config :kindle_extractor,
  ecto_repos: [KindleExtractor.Repo]

config :kindle_extractor, KindleExtractor.Repo,
  database: "vocab.db"
