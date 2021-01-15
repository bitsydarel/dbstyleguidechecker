import 'dart:async';
import 'dart:io';

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:args/args.dart';

/// Run the script with the provided [arguments].
Future<void> main(List<String> arguments) async {
  ArgResults argResults;

  try {
    argResults = argumentParser.parse(arguments);
  } on Exception catch (_) {
    printHelpMessage('Invalid parameter specified.');
    exitCode = exitInvalidArgument;
    return;
  }

  if (argResults.wasParsed(helpParameter)) {
    printHelpMessage();
    exitCode = 0;
    return;
  }

  ScriptArgument scriptArgument;

  try {
    scriptArgument = ScriptArgument.from(argResults);
  } on UnrecoverableException catch (exception) {
    printHelpMessage(exception.reason);
    exitCode = exception.exitCode;
    return;
  }

  Directory.current = scriptArgument.projectDir.path;

  CodeStylesViolationsReporter reporter;

  try {
    reporter = _createReporter(scriptArgument);
  } on UnrecoverableException catch (exception) {
    printHelpMessage(exception.reason);
    exitCode = exception.exitCode;
    return;
  }

  CodeStyleViolationsChecker checker;

  try {
    checker = createParser(scriptArgument, reporter);
  } on UnrecoverableException catch (exception) {
    printHelpMessage(exception.reason);
    exitCode = exception.exitCode;
    return;
  }

  runZoned<void>(checker.check, onError: (Object error, StackTrace stackTrace) {
    printHelpMessage(error.toString());
    if (error is UnrecoverableException) {
      exitCode = error.exitCode;
    } else {
      exitCode = exitUnexpectedError;
    }
  });
}

CodeStyleViolationsChecker createParser(
  ScriptArgument scriptArgument,
  CodeStylesViolationsReporter reporter,
) {
  switch (scriptArgument.projectType) {
    case dartProjectType:
      return DartProjectStyleGuideChecker(
        scriptArgument.codeStyle,
        scriptArgument.projectDir,
        const DartAnalyzerViolationParser(),
        reporter,
      );
      break;
    case flutterProjectType:
      return FlutterProjectStyleGuideChecker(
        scriptArgument.codeStyle,
        scriptArgument.projectDir,
        const DartAnalyzerViolationParser(),
        reporter,
      );
      break;
    default:
      throw UnrecoverableException(
        'Invalid project type specified, '
        "supported are ${supportedProjectType.join(", ")}",
        exitInvalidArgument,
      );
  }
}

CodeStylesViolationsReporter _createReporter(ScriptArgument scriptArgument) {
  switch (scriptArgument.reporterType) {
    case reporterOfTypeConsole:
      return const ConsoleCodeStyleViolationsReporter();
      break;
    case reporterOfTypeFile:
      final File reporterOutputFile = scriptArgument.reporterOutputFile;

      if (reporterOutputFile == null) {
        throw UnrecoverableException(
          "Reporter of type 'file' specified "
          'but reporter output file not specified.',
          exitMissingRequiredArgument,
        );
      }
      return FileCodeStyleViolationsReporter(reporterOutputFile);
      break;
    case reporterOfTypeGithub:
      final VcsArgument vcs = scriptArgument.vcs;

      if (vcs == null) {
        throw UnrecoverableException(
          "Reporter of type 'github' specified but vcs parameter not specified",
          exitMissingRequiredArgument,
        );
      }

      return GithubPullRequestStyleGuideCheckReporter(
        getGithubRepoOwner(vcs.repoUrl),
        getGithubRepoName(vcs.repoUrl),
        vcs.pullRequestId,
        vcs.accessToken,
      );
      break;
    default:
      throw UnrecoverableException(
        'Invalid reporter type provided or not supported',
        exitInvalidArgument,
      );
  }
}
