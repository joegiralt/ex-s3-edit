defmodule ExS3Edit do
  use Bakeware.Script
  alias ExS3Edit.Cli

  @impl Bakeware.Script

  def main(args) when is_list(args) do
    args
    |> parse_args()
    |> handle_commands()
  end

  def main(_args), do: 0
  def main(), do: 0

  defp parse_args(args) do
    {opts, word, _} =
      args
      |> OptionParser.parse(
        switches: [
          edit: :boolean,
          list: :boolean,
          help: :boolean,
          read: :boolean,
          version: :boolean
        ]
      )

    {opts, List.to_string(word)}
  end

  defp handle_commands({opts, flag_value}) do
    case List.first(opts) do
      {:edit, _} -> Cli.command(:edit, flag_value)
      {:read, _} -> Cli.command(:read, flag_value)
      {:help, _} -> Cli.command(:help)
      {:list, _} -> Cli.command(:list)
      {:version, _} -> Cli.command(:version)
      _ -> Cli.command(:unknown)
    end
    |> IO.puts()

    0
  end
end
