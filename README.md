# dbstyleguidechecker

A code style violations script for dart, flutter and other.

## Overview

A command-line tool that help you verify a code style against a project.

It's help you automate your code style check on a vcs pull requests, example: github.

[license](https://github.com/bitsydarel/dbstyleguidechecker/blob/master/LICENSE).

<br>

## Installation

For usage everywhere in the system.

```bash
pub global activate dbstyleguidechecker
```

For usage only in the current package.

```bash
pub activate dbstyleguidechecker
```
<br>

<br>

## Usage

```bash
dbstyleguidechecker --project-type [project type] [local project directory]
```

Options:

--code-style specify the code style guide to use (defaults to "analysis_options.yaml")

--project-type specify the type of project to analyze, default to "dart", available options are ["dart", "flutter"]

--reporter-type specify the reporter type, default to 'console', available are ['console', 'file', 'github']

--vcs-url repository to push code style violations on the pull request (currently supported only for reporter type
github).

--vcs-pull-request-id to push code style violations on (currently supported only for reporter type github).

--vcs-access-token api access token used to push code style violations on pull request (currently supported only for
reporter type github).

--reporter-output-file where code violation will be reported (currently supported only for reporter type file).

--help print help message

<br>

<br>

## Example

Use code style from different location then current project or different file name.

```bash
dbstyleguidechecker --project-type dart --code-style [path to code style file] example
```

Report code style violations to console.

```bash
dbstyleguidechecker --project-type dart example
```

Report code style violations to github

```bash
dbstyleguidechecker --project-type dart --reporter-type github --vcs-url https://github.com/bitsydarel/dbstyleguidechecker --vcs-pull-request-id [pull-request-id] --vcs-access-token [github-api-access-token] example
```

Report code style violations to file.

```bash
dbstyleguidechecker --project-type dart --reporter-type file --reporter-output-file example/log.txt example
```

<br>