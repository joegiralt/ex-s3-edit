defmodule ExS3Edit.Cli do
  alias ExS3Edit.TmpFileUtil
  alias ExS3Edit.Editor
  alias ExS3Edit.S3

  def command(:list) do
    S3.fetch_bucket_names()
    |> Enum.map(fn bucket_name ->
      S3.fetch_files(bucket_name)
    end)
    |> List.flatten()
  end

  def command(:help) do
    """
     --help          Surfaces this help prompt

      --edit          Expects a s3 path
                      example: --edit s3://your-bucket/your-file.txt

      --read          Prints body to screen
                      example: --read s3://your-bucket/your-file.txt

      --list          Lists all files in all s3 buckets
    """
  end

  def command(:unknown) do
    "Oops that didn't work! \n\n #{command(:help)}"
  end

  def command(:edit, path) do
    with {:ok, raw_uri} <- URI.new(path),
         {:ok, file_name, file_body} <- S3.fetch_file(raw_uri),
         {:ok, _msg} <- TmpFileUtil.write(file_name, file_body) do
      Editor.open_with_default(file_name)
      S3.save_file!(file_name, raw_uri.host, raw_uri.path)
      TmpFileUtil.remove(file_name)
    else
      err -> err
    end
  end

  def command(:read, path) do
    with {:ok, raw_uri} <- URI.new(path),
         {:ok, _file_name, file_body} <- S3.fetch_file(raw_uri) do
      """
      S3 Path:
        #{path}

      File Body:
        #{file_body}

      """
    else
      err -> err
    end
  end
end
