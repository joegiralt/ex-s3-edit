defmodule ExS3Edit.TmpFileUtil do
  def write(file_name, file_body) do
    case File.write(file_name, file_body) do
      :ok -> {:ok, "successful write!"}
      msg -> msg
    end
  end

  def remove(file_name) do
    File.rm(file_name)
  end
end
