Mix.install([
  {:explorer, "~> 0.1.0-dev", github: "elixir-nx/explorer", branch: "main"},
  {:scidata, "~> 0.1.3"}
])

entries = Scidata.Squad.download()
tables = Scidata.Squad.to_maps(entries)
{titles, contexts, qas} = tables

qa_df = Explorer.DataFrame.from_map(qas)

titles_df = Explorer.DataFrame.from_map(titles)
contexts_df = Explorer.DataFrame.from_map(contexts)
tc_df = Explorer.DataFrame.join(titles_df, contexts_df)

squad_df = Explorer.DataFrame.join(tc_df, qa_df)
