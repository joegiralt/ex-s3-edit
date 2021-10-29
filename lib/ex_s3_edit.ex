defmodule ExS3Edit do
  use Bakeware.Script
  alias ExAws.S3
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
        switches: [edit: :boolean, list: :boolean, help: :boolean, read: :boolean]
      )

    {opts, List.to_string(word)}
  end

  defp handle_commands({opts, flag_value}) do
    case List.first(opts) do
      {:edit, _} -> command(:edit, flag_value)
      {:read, _} -> command(:read, flag_value)
      {:help, _} -> command(:help)
      {:list, _} -> command(:list)
      _ -> command(:unknown)
    end
    |> IO.puts()

    0
  end

  @spec command(:help | :list | :unknown) :: <<_::64, _::_*8>> | list
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

  def command(:list) do
    fetch_all_bucket_names()
    |> Enum.map(fn bucket_name ->
      fetch_all_files(bucket_name)
    end)
    |> List.flatten()
  end

  def command(:unknown) do
    "Oops that didn't work! \n\n #{command(:help)}"
  end

  def command(:edit, path) do
    with {:ok, raw_uri} <- URI.new(path),
         {:ok, file_name, file_body} <- fetch_file_from_s3(raw_uri),
         {:ok, _msg} <- write_to_tmp(file_name, file_body) do
      spawn_default_editor(file_name)

      save_file_to_s3!(file_name, raw_uri.host, raw_uri.path)

      remove_from_tmp(file_name)
    else
      err -> err
    end
  end

  def command(:read, path) do
    with {:ok, raw_uri} <- URI.new(path),
         {:ok, _file_name, file_body} <- fetch_file_from_s3(raw_uri) do
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

  def request_object_from_s3(valid_uri) do
    req =
      S3.get_object(valid_uri.host, valid_uri.path)
      |> ExAws.request!()

    case req.status_code do
      200 -> {:ok, req.body}
      _ -> {:error, "API Error: #{req}"}
    end
  end

  def fetch_file_from_s3(raw_uri) do
    with {:ok, valid_uri} <- validate_uri_scheme(raw_uri),
         {:ok, file_body} <- request_object_from_s3(valid_uri) do
      {:ok, file_name(valid_uri.path), file_body}
    else
      err -> err
    end
  end

  def write_to_tmp(file_name, file_body) do
    case File.write(file_name, file_body) do
      :ok -> {:ok, "successful write!"}
      msg -> msg
    end
  end

  def remove_from_tmp(file_name) do
    File.rm(file_name)
  end

  def spawn_default_editor(file_name) do
    port = Port.open({:spawn, "#{default_editor()} #{file_name}"}, [:nouse_stdio, :exit_status])

    receive do
      {^port, {:exit_status, exit_status}} ->
        IO.puts("#{default_editor()} exited with #{exit_status}")
    end
  end

  def save_file_to_s3!(local, bucket, path) do
    local_file = File.read!(local)

    S3.put_object(bucket, path, local_file)
    |> ExAws.request()
  end

  def fetch_all_bucket_names do
    S3.list_buckets()
    |> ExAws.request!()
    |> Map.get(:body)
    |> Map.get(:buckets)
    |> Enum.map(fn elem -> elem[:name] end)
  end

  def fetch_all_files(bucket_name) do
    S3.list_objects(bucket_name)
    |> ExAws.request!()
    |> Map.get(:body)
    |> Map.get(:contents)
    |> Enum.map(fn s3_obj ->
      format_s3_paths_for(s3_obj[:key], bucket_name)
    end)
  end

  def validate_uri_scheme(%URI{scheme: "s3"} = uri), do: {:ok, uri}

  def validate_uri_scheme(uri) do
    {:error, "Please check S3 path name, should beging with `s3`, not `#{uri.scheme}`"}
  end

  def format_s3_paths_for(file_path, bucket_name) do
    "s3://#{bucket_name}/#{file_path}\n"
  end

  def file_name(path) do
    path
    |> String.split("/")
    |> List.last()
  end

  def default_editor do
    System.get_env("EDITOR") || "vi"
  end
end
