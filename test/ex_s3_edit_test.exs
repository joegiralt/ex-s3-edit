defmodule ExS3EditTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  doctest ExS3Edit

  test "main with no args returns 0" do
    assert ExS3Edit.main() == 0
  end

  test "main with args other than a list returns 0" do
    assert ExS3Edit.main({:foo}) == 0
    assert ExS3Edit.main(nil) == 0
    assert ExS3Edit.main(:bar) == 0
    assert ExS3Edit.main("bravo") == 0
    assert ExS3Edit.main(%{a: :b}) == 0
  end

  test "main with --help,  has info about four flags" do
    help_msg = capture_io(fn -> ExS3Edit.main(["--help"]) end)

    assert String.contains?(help_msg, "--help")
    assert String.contains?(help_msg, "--edit")
    assert String.contains?(help_msg, "--read")
    assert String.contains?(help_msg, "--list")
    assert String.contains?(help_msg, "--version")
  end

  test "main with unknown command should tell user its doesn't recognise command" do
    help_msg = capture_io(fn -> ExS3Edit.main(["--chickens"]) end)

    assert String.contains?(help_msg, "Oops that didn't work!")
  end

  test "main with --version should output version " do
    version = capture_io(fn -> ExS3Edit.main(["--version"]) end)

    assert String.contains?(version, ExS3Edit.MixProject.project()[:version])
  end
end
