/*
 * BSD 3-Clause License
 *
 * Copyright (c) 2020, Bitsy Darel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

  CodeStyleViolationsChecker checker;

  try {
    final CodeStyleViolationsReporter reporter =
        _createReporter(scriptArgument);

    checker = _createChecker(scriptArgument, reporter);
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

CodeStyleViolationsChecker _createChecker(
  final ScriptArgument scriptArgument,
  final CodeStyleViolationsReporter reporter,
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

CodeStyleViolationsReporter _createReporter(
  final ScriptArgument scriptArgument,
) {
  switch (scriptArgument.reporterType) {
    case reporterOfTypeConsole:
      return const ConsoleCodeStyleViolationsReporter();
    case reporterOfTypeFile:
      final File reporterOutputFile = scriptArgument.reporterOutputFile;

      if (reporterOutputFile == null) {
        throw const UnrecoverableException(
          "Reporter of type 'file' specified "
              'but reporter output file not specified.',
          exitMissingRequiredArgument,
        );
      }
      return FileCodeStyleViolationsReporter(reporterOutputFile);
    case reporterOfTypeGithub:
      final VcsArgument vcs = scriptArgument.vcs;

      if (vcs == null) {
        throw const UnrecoverableException(
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
    case reporterOfTypeJson:
      return const JsonCodeStyleViolationReporter();
    default:
      throw const UnrecoverableException(
        'Invalid reporter type provided or not supported',
        exitInvalidArgument,
      );
  }
}
