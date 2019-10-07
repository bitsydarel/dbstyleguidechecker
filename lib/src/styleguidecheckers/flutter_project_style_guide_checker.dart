import "dart:convert";
import "dart:io";

import "package:dbstyleguidechecker/dbstyleguidechecker.dart";
import "package:dbstyleguidechecker/src/expections.dart";

/// Flutter project style guide linter.
class FlutterProjectStyleGuideChecker extends DartProjectStyleGuideChecker {
  /// create a Flutter code style guide linter.
  const FlutterProjectStyleGuideChecker(
    File styleGuide,
    Directory projectDir,
    DBStyleGuideViolationParser parser,
    DBStyleGuideCheckReporter reporter,
  ) : super(styleGuide, projectDir, parser, reporter);

  @override
  Future<void> runPubGet() {
    return Process.run(
      "flutter",
      ["packages", "get"],
      runInShell: true,
      stdoutEncoding: utf8,
    ).then<void>((result) {
      final errorOutput = result.stderr.toString();

      if (errorOutput.isNotEmpty) {
        throw UnrecoverableException(
          "could not run flutter packages get: $errorOutput",
          exitPackageUpdatedFailed,
        );
      }
    });
  }
}
