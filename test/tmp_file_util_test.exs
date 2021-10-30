defmodule TmpFileUtilTest do
  use ExUnit.Case
  doctest ExS3Edit.TmpFileUtil

  test "write, should write a file" do
    file_name = "foo.txt"
    body = "bar"
    ExS3Edit.TmpFileUtil.write(file_name, body)
    assert File.read(file_name) == {:ok, body}
  end

  test "remove, should remove a file" do
    file_name = "foo.txt"
    body = "bar"
    ExS3Edit.TmpFileUtil.write(file_name, body)
    assert File.read(file_name) == {:ok, body}
    ExS3Edit.TmpFileUtil.remove(file_name)
    assert File.read(file_name) == {:error, :enoent}
  end
end
