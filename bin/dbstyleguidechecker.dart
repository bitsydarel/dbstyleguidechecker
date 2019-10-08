import "dart:async";
import "dart:convert";
import "dart:io";
import "package:io/ansi.dart";

import "package:dbstyleguidechecker/dbstyleguidechecker.dart";
import "package:args/args.dart";

const String styleGuide = "style-guide";
const String flutterProject = "flutter";
const String githubRepoUrl = "github-repo";
const String githubPullRequestId = "github-pull-request-id";
const String githubApiToken = "github-api-token";
const String help = "help";

final _argumentParser = ArgParser()
  ..addOption(
    styleGuide,
    abbr: "s",
    defaultsTo: "analysis_options.yaml",
    help: "specify the code style guide to use",
  )
  ..addFlag(
    flutterProject,
    abbr: "f",
    defaultsTo: false,
    help: "should be added if it's flutter project",
  )
  ..addOption(
    githubRepoUrl,
    abbr: "g",
    defaultsTo: "",
    help: "github repository to push style guide violation on the pull request",
  )
  ..addOption(
    githubPullRequestId,
    abbr: "p",
    help: "github pull request id",
  )
  ..addOption(
    githubApiToken,
    abbr: "t",
    defaultsTo: "",
    help: "github api access token",
  )
  ..addFlag(
    help,
    abbr: "h",
    help: "print help message",
  );

void _printHelpMessage([final String message]) {
  if (message != null) {
    print(red.wrap("$message\n"));
  }

  final options =
      LineSplitter.split(_argumentParser.usage).map((l) => "$l").join("\n");

  print(
    "Usage: dbstyleguidechecker --style-guide "
    "<path to analysis_options.yaml> <local project directory>"
    "\nOptions: $options",
  );
}

void main(List<String> arguments) async {
  ArgResults argResults;

  try {
    argResults = _argumentParser.parse(arguments);
  } on Exception catch (_) {
    _printHelpMessage("Invalid parameter specified.");
    exitCode = exitInvalidArgument;
    return;
  }

  if (argResults.wasParsed(help)) {
    _printHelpMessage();
    exitCode = 0;
    return;
  }

  if (!argResults.wasParsed(styleGuide)) {
    _printHelpMessage("$styleGuide parameter is required");
    exitCode = exitMissingRequiredArgument;
    return;
  }

  if (argResults.rest.length != 1) {
    _printHelpMessage("invalid project dir path");
    exitCode = exitInvalidArgument;
    return;
  }

  final projectDir = getResolvedProjectDir(argResults.rest[0]);

  if (!projectDir.existsSync()) {
    _printHelpMessage("specified local project dir does not exist");
    exitCode = exitInvalidArgument;
    return;
  }

  final styleGuideFile = getStyleGuideFile(
    argResults[styleGuide] as String,
    projectDir.path,
  );

  if (!styleGuideFile.existsSync()) {
    _printHelpMessage("specified $styleGuide parameter file does not exist");
    exitCode = exitInvalidArgument;
    return;
  }

  final repoUrl = argResults[githubRepoUrl] as String;

  final pullReqId = int.tryParse(
    argResults[githubPullRequestId] as String ?? "",
  );

  final apiToken = argResults[githubApiToken] as String;

  if (repoUrl.isNotEmpty && (pullReqId == null || apiToken.isEmpty)) {
    _printHelpMessage("Pull request id or api token is not specified");
    exitCode = exitMissingRequiredArgument;
    return;
  }

  if (pullReqId != null && (repoUrl.isEmpty || apiToken.isEmpty)) {
    _printHelpMessage(
      "Github repository url or github api token is not specified",
    );
    exitCode = exitMissingRequiredArgument;
    return;
  }

  if (apiToken.isNotEmpty && (repoUrl.isEmpty || pullReqId == null)) {
    _printHelpMessage(
      "Github repository url or github pull request id is not specified",
    );
    exitCode = exitMissingRequiredArgument;
    return;
  }

  Directory.current = projectDir;

  final isFlutterProject = argResults[flutterProject] as bool;

  final DBStyleGuideViolationParser parser =
      const DartAnalyzerViolationParser();

  final reporter = pullReqId == null
      ? const ConsoleStyleGuideCheckReporter()
      : GithubPullRequestStyleGuideCheckReporter(
          getGithubRepoOwner(repoUrl),
          getGithubRepoName(repoUrl),
          pullReqId,
          apiToken,
        );

  final DBStyleGuideChecker checker = isFlutterProject
      ? FlutterProjectStyleGuideChecker(
          styleGuideFile,
          projectDir,
          parser,
          reporter,
        )
      : DartProjectStyleGuideChecker(
          styleGuideFile, projectDir, parser, reporter);

  runZoned<void>(checker.check, onError: (Object error, StackTrace stackTrace) {
    _printHelpMessage(error.toString());
    if (error is UnrecoverableException) {
      exitCode = error.exitCode;
    } else {
      exitCode = exitUnexpectedError;
    }
  });
}
