library dbstyleguidechecker;

import 'dart:io';
import 'package:meta/meta.dart' show protected;

import 'package:dbstyleguidechecker/src/style_guide_violation.dart';

export 'package:dbstyleguidechecker/src/checkers/dart/dart_project_style_guide_checker.dart';
export 'package:dbstyleguidechecker/src/checkers/dart/flutter_project_style_guide_checker.dart';
export 'package:dbstyleguidechecker/src/reporters/console_code_style_violations_reporter.dart';
export 'package:dbstyleguidechecker/src/reporters/github/github_pull_request_style_guide_check_reporter.dart';
export 'package:dbstyleguidechecker/src/reporters/file_style_guide_violation_reporter.dart';
export 'package:dbstyleguidechecker/src/parsers/dart/dart_analyzer_violation_parser.dart';
export 'package:dbstyleguidechecker/src/exceptions.dart';
export 'package:dbstyleguidechecker/src/utils/script_utils.dart';
export 'package:dbstyleguidechecker/src/reporters/github/github_utils.dart';

/// Style guide linter.
///
/// Verify a coding style guide against a project.
abstract class CodeStyleViolationsChecker {
  /// style guide to verify.
  final File styleGuide;

  /// project directory containing the code.
  final Directory projectDir;

  /// Parse founded style check violations.
  final CodeStyleViolationsParser parser;

  /// Report founded style check violations.
  final CodeStylesViolationsReporter reporter;

  /// create a [CodeStyleViolationsChecker].
  ///
  /// [styleGuide] to use.
  ///
  /// [projectDir] to apply the [styleGuide] to.
  ///
  /// [parser] to parse founded style guide violations.
  ///
  /// [reporter] to report founded style guide violations.
  const CodeStyleViolationsChecker(
    this.styleGuide,
    this.projectDir,
    this.parser,
    this.reporter,
  );

  /// Run the checker.
  Future<void> check() async {
    final String unParsedViolations = await getCodeStyleViolations();

    final List<CodeStyleViolation> parsedViolations = await parser.parse(
      unParsedViolations,
      projectDir.path,
    );

    await reporter.report(parsedViolations);
  }

  /// Found [styleGuide] violations from the [projectDir].
  @protected
  Future<String> getCodeStyleViolations();
}

/// Style guide violations reporter.
///
/// Report style guide violations.
abstract class CodeStylesViolationsReporter {
  /// Create a constant instance of a [CodeStylesViolationsReporter].
  const CodeStylesViolationsReporter();

  /// Report [violations].
  Future<void> report(final List<CodeStyleViolation> violations);
}

/// Style guide violation parser.
///
/// Parse founded violations.
abstract class CodeStyleViolationsParser {
  /// Create a constant instance of a [CodeStyleViolationsParser].
  const CodeStyleViolationsParser();

  /// Parse violations contained in the [violations].
  ///
  /// [projectDir] the violations are coming from.
  Future<List<CodeStyleViolation>> parse(
    final String violations,
    final String projectDir,
  );
}
