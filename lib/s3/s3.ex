defmodule ExS3Edit.S3 do
  def request_object(valid_uri) do
    req =
      ExAws.S3.get_object(valid_uri.host, valid_uri.path)
      |> ExAws.request!()

    case req.status_code do
      200 -> {:ok, req.body}
      _ -> {:error, "API Error: #{req}"}
    end
  end

  def fetch_file(raw_uri) do
    with {:ok, valid_uri} <- validate_uri_scheme(raw_uri),
         {:ok, file_body} <- request_object(valid_uri) do
      {:ok, file_name(valid_uri.path), file_body}
    else
      err -> err
    end
  end

  def save_file!(local, bucket, path) do
    local_file = File.read!(local)

    ExAws.S3.put_object(bucket, path, local_file)
    |> ExAws.request()
  end

  def fetch_bucket_names do
    ExAws.S3.list_buckets()
    |> ExAws.request!()
    |> Map.get(:body)
    |> Map.get(:buckets)
    |> Enum.map(fn elem -> elem[:name] end)
  end

  def fetch_files(bucket_name) do
    ExAws.S3.list_objects(bucket_name)
    |> ExAws.request!()
    |> Map.get(:body)
    |> Map.get(:contents)
    |> Enum.map(fn s3_obj ->
      format_s3_paths_for(s3_obj[:key], bucket_name)
    end)
  end

  defp validate_uri_scheme(%URI{scheme: "s3"} = uri), do: {:ok, uri}

  defp validate_uri_scheme(uri) do
    {:error, "Please check S3 path name, should beging with `s3`, not `#{uri.scheme}`"}
  end

  defp file_name(path) do
    path
    |> String.split("/")
    |> List.last()
  end

  defp format_s3_paths_for(file_path, bucket_name) do
    "s3://#{bucket_name}/#{file_path}\n"
  end
end
