import 'dart:convert';
import 'dart:io';
import 'package:meta/meta.dart' show protected;

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/exceptions.dart';

/// Dart project style guide linter.
class DartProjectStyleGuideChecker extends CodeStyleViolationsChecker {
  /// create a Dart code style guide linter.
  const DartProjectStyleGuideChecker(
    File styleGuide,
    Directory projectDir,
    CodeStyleViolationsParser parser,
    CodeStylesViolationsReporter reporter,
  ) : super(styleGuide, projectDir, parser, reporter);

  @override
  Future<String> getCodeStyleViolations() {
    return runPubGet().then(
      (_) => Process.run(
        'dartanalyzer',
        <String>[
          '--format',
          'machine',
          '--options',
          styleGuide.path,
          projectDir.path,
        ],
        runInShell: true,
        stdoutEncoding: utf8,
      ).then((ProcessResult processResult) {
        final String output = processResult.stdout.toString();

        return output.isEmpty ? processResult.stderr.toString() : output;
      }),
    );
  }

  /// Run the
  @protected
  Future<void> runPubGet() {
    return Process.run(
      'pub',
      <String>['get'],
      runInShell: true,
      stdoutEncoding: utf8,
    ).then<void>((ProcessResult result) {
      final String errorOutput = result.stderr.toString();

      if (errorOutput.isNotEmpty) {
        throw UnrecoverableException(
          'could not run pub get: $errorOutput',
          exitPackageUpdatedFailed,
        );
      }
      return;
    });
  }
}
