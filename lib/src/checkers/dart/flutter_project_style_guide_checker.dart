import 'dart:convert';
import 'dart:io';

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/exceptions.dart';

import 'package:dbstyleguidechecker/src/checkers/dart/dart_project_style_guide_checker.dart';

/// Flutter project style guide linter.
class FlutterProjectStyleGuideChecker extends DartProjectStyleGuideChecker {
  /// create a Flutter code style guide linter.
  const FlutterProjectStyleGuideChecker(
    File styleGuide,
    Directory projectDir,
    CodeStyleViolationsParser parser,
    CodeStylesViolationsReporter reporter,
  ) : super(styleGuide, projectDir, parser, reporter);

  @override
  Future<void> runPubGet() {
    return Process.run(
      'flutter',
      <String>['packages', 'get'],
      runInShell: true,
      stdoutEncoding: utf8,
    ).then<void>((ProcessResult result) {
      final String errorOutput = result.stderr.toString();

      if (errorOutput.isNotEmpty) {
        throw UnrecoverableException(
          'could not run flutter packages get: $errorOutput',
          exitPackageUpdatedFailed,
        );
      }
    });
  }
}
