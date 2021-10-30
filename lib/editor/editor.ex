defmodule ExS3Edit.Editor do
  @moduledoc """
    Functions for handling finding and opening the default editor
    for the user's CLI
  """
  def open_with_default(file_name) do
    port = Port.open({:spawn, "#{default_editor()} #{file_name}"}, [:nouse_stdio, :exit_status])

    receive do
      {^port, {:exit_status, exit_status}} ->
        IO.puts("#{default_editor()} exited with #{exit_status}")
    end
  end

  defp default_editor do
    System.get_env("EDITOR") || "vi"
  end
end
