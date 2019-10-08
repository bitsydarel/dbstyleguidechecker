A command-line tool that help you verify that a project follow a specific code style guideline.

It's also help you automate your code style guideline check on github pull requests.

[license](https://github.com/bitsydarel/dbstyleguidechecker/blob/master/LICENSE).

Usage: dbstyleguidechecker --style-guide <path to analysis_options.yaml> <local project directory>

Options: -s, --style-guide      specify the code style guide to use (defaults to "analysis_options.yaml")

-f, --[no-]flutter              should be added if it's flutter project

-g, --github-repo               github repository to push style guide violation on the pull request (defaults to "")

-p, --github-pull-request-id    github pull request id

-t, --github-api-token          github api access token (defaults to "")

-h, --[no-]help                 print help message
