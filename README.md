# ex-s3-edit
Edit files directly on Amazon S3 in CLI
[![CircleCI branch](https://img.shields.io/circleci/project/github/joegiralt/ex-s3-edit/main.svg?style=flat-square)](https://circleci.com/gh/joegiralt/ex-s3-edit/tree/main)
[![MIT license](https://img.shields.io/github/license/joegiralt/ex-s3-edit.svg?style=flat-square)](https://github.com/joegiralt/ex-s3-edit/blob/main/LICENSE)

Directly inspired by [s3-edit](https://github.com/tsub/s3-edit) written in Go by [tsub](https://github.com/tsub).

## Installation

### Install with Homebrew

For macOS(ARM and Intel) and Linux(coming soon)

```
$ brew install joegiralt/ex-s3-edit/ex-s3-edit
```

### Get binary from GitHub releases

Download latest binary from https://github.com/joegiralt/ex-s3-edit/releases

## Requirements

* AWS credentials
* Upload files to S3 in advance

For examples, use aws-cli

```bash
$ aws configure --profile myaccount
$ export AWS_PROFILE=myaccount
```

Other methods,

```bash
$ export AWS_ACCESS_KEY_ID=xxxx
$ export AWS_SECRET_ACCESS_KEY=xxxx
$ export AWS_REGION=ap-northeast-1
```

## Usage

Upload the file to S3 in advance.

```bash
$ echo "This is a test file." > myfile.txt
$ aws s3 cp test.txt s3://mybucket/myfile.txt
```

To directly edit a file on S3, use `--edit` subcommand.

```bash
$ ex_s3_edit --edit s3://mybucket/myfile.txt
```
Then a file will open with the default editor specified by `$EDITOR` or `EDITOR`.

To view a list of all files in S3, use `--list` subcommand.

```bash
$ ex_s3_edit --list
```

To view the contents of a specific file in S3, use `--read` subcommand.

```bash
$ ex_s3_edit --read s3://mybucket/myfile.txt
```

## Development

### Requirements

* Elixir >= 1.12.3
* Erlang >= 24.1.3
### To run in iex interactive mode
```bash
$ iex -S mix run --no-start
```
### To run tests
```bash
$ mix test --no-start
```
### To build binary
```bash
$ mix release
```