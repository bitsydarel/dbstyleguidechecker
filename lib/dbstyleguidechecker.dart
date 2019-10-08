library dbstyleguidechecker;

import "dart:io";
import "package:meta/meta.dart" show protected;

import "package:dbstyleguidechecker/src/style_guide_violation.dart";

export "package:dbstyleguidechecker/src/styleguidecheckers/dart_project_style_guide_checker.dart";
export "package:dbstyleguidechecker/src/styleguidecheckers/flutter_project_style_guide_checker.dart";
export "package:dbstyleguidechecker/src/styleguidecheckreports/console_style_guide_check_reporter.dart";
export "package:dbstyleguidechecker/src/styleguidecheckreports/github/github_pull_request_style_guide_check_reporter.dart";
export "package:dbstyleguidechecker/src/styleguideviolationparsers/dart_analyzer_violation_parser.dart";
export "package:dbstyleguidechecker/src/expections.dart";
export "package:dbstyleguidechecker/src/utils/file_utils.dart";

/// Style guide linter.
///
/// Verify a coding style guide against a project.
abstract class DBStyleGuideChecker {
  /// create a [DBStyleGuideChecker].
  ///
  /// [styleGuide] to use.
  ///
  /// [projectDir] to apply the [styleGuide] to.
  ///
  /// [_parser] to parse founded style guide violations.
  ///
  /// [_reporter] to report founded style guide violations.
  const DBStyleGuideChecker(
    this.styleGuide,
    this.projectDir,
    this._parser,
    this._reporter,
  );

  /// style guide to verify.
  final File styleGuide;

  /// project directory containing the code.
  final Directory projectDir;

  /// Parse founded style check violations.
  final DBStyleGuideViolationParser _parser;

  /// Report founded style check violations.
  final DBStyleGuideCheckReporter _reporter;

  /// Run the checker.
  Future<void> check() async {
    final rawViolations = await foundStyleCheckViolations();

    final parsedViolations = await _parser.parse(
      rawViolations,
      projectDir.path,
    );

    await _reporter.report(parsedViolations);
  }

  /// Found [styleGuide] violations from the [projectDir].
  @protected
  Future<String> foundStyleCheckViolations();
}

/// Style guide check reporter.
///
/// Report style guide violation.
abstract class DBStyleGuideCheckReporter {
  /// Create a constant instance of a [DBStyleGuideCheckReporter].
  const DBStyleGuideCheckReporter();

  /// Report [violations].
  Future report(final List<StyleGuideViolation> violations);
}

/// Style guide violation parser.
///
/// Parse founded violations.
abstract class DBStyleGuideViolationParser {
  /// Create a constant instance of a [DBStyleGuideViolationParser].
  const DBStyleGuideViolationParser();

  /// Parse violations contained in the [violations].
  ///
  /// [projectDir] the violations are coming from.
  Future<List<StyleGuideViolation>> parse(
    final String violations,
    final String projectDir,
  );
}
