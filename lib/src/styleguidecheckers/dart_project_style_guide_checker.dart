import "dart:convert";
import "dart:io";
import "package:meta/meta.dart" show protected;

import "package:dbstyleguidechecker/dbstyleguidechecker.dart";
import "package:dbstyleguidechecker/src/expections.dart";

/// Dart project style guide linter.
class DartProjectStyleGuideChecker extends DBStyleGuideChecker {
  /// create a Dart code style guide linter.
  const DartProjectStyleGuideChecker(
    File styleGuide,
    Directory projectDir,
    DBStyleGuideViolationParser parser,
    DBStyleGuideCheckReporter reporter,
  ) : super(styleGuide, projectDir, parser, reporter);

  @override
  Future<String> foundStyleCheckViolations() {
    return runPubGet().then(
      (_) => Process.run(
        "dartanalyzer",
        ["--format", "machine", "--options", styleGuide.path, projectDir.path],
        runInShell: true,
        stdoutEncoding: utf8,
      ).then((processResult) {
        final output = processResult.stdout.toString();
        return output.isEmpty ? processResult.stderr.toString() : output;
      }),
    );
  }

  /// Run the
  @protected
  Future<void> runPubGet() {
    return Process.run(
      "pub",
      ["get"],
      runInShell: true,
      stdoutEncoding: utf8,
    ).then<void>((result) {
      final errorOutput = result.stderr.toString();

      if (errorOutput.isNotEmpty) {
        throw UnrecoverableException(
          "could not run pub get: $errorOutput",
          exitPackageUpdatedFailed,
        );
      }
      return;
    });
  }
}
