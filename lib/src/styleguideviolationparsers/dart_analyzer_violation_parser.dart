import "dart:convert" show LineSplitter;

import "package:dbstyleguidechecker/dbstyleguidelinter.dart";
import "package:dbstyleguidechecker/src/style_guide_violation.dart";
import "package:dbstyleguidechecker/src/utils/file_utils.dart";
import "package:meta/meta.dart" show visibleForTesting;

/// Dart analyzer violation parser.
class DartAnalyzerViolationParser extends DBStyleGuideViolationParser {
  ///
  const DartAnalyzerViolationParser();

  /// The regular expression that parse a lint line parser.
  static final RegExp _regexp = RegExp(
    // ignore: prefer_interpolation_to_compose_strings
    "^" + // beginning of line
        "([\\w_\\.]+)\\|" * 3 + // first three error notes
        "([^\\|]+)\\|" + // file path
        "([\\w_\\.]+)\\|" * 3 + // line, column, length
        "(.*?)" + // rest is the error message
        "\$", // end of line
  );

  @override
  Future<List<StyleGuideViolation>> parse(
    String violations,
    String projectDir,
  ) async {
    final parsedViolations = <StyleGuideViolation>[];

    for (final violation in LineSplitter.split(violations)) {
      parsedViolations.add(
        parseStyleGuideViolation(violation, projectDir),
      );
    }

    return List.unmodifiable(parsedViolations);
  }

  /// Parse a lint result line.
  ///
  /// [violation] to be parsed.
  ///
  /// [projectDir] containing this file.
  @visibleForTesting
  StyleGuideViolation parseStyleGuideViolation(
    final String violation, [
    String projectDir,
  ]) {
    if (violation.isEmpty) {
      throw const UnrecoverableException(
        "violation check is empty",
        exitParsingViolationFailed,
      );
    }

    final matches = _regexp.allMatches(violation);

    if (matches.isEmpty) {
      if (violation.endsWith("is a part and cannot be analyzed.")) {
        var filePath = violation.split(" ").first;

        if (projectDir != null) {
          filePath = getFileRelativePath(filePath, projectDir);
        }

        return StyleGuideViolation.invalid(filePath);
      }

      throw UnrecoverableException(
        "Does not match any of the expected value: $violation ",
        exitParsingViolationFailed,
      );
    } else {
      final result = matches.single;

      final lintSeverity = ViolationSeverity.withId(result[1]);
      final lintType = result[2];
      final lintRule = result[3];

      var filePath = result[4];

      if (projectDir != null) {
        filePath = getFileRelativePath(filePath, projectDir);
      }

      final lineNumber = int.parse(result[5]);
      final lineColumn = int.parse(result[6]);
      final lintRuleDescription = result[8];

      return StyleGuideViolation(
        lintSeverity,
        lintType,
        filePath,
        lineNumber,
        lineColumn,
        lintRule,
        lintRuleDescription,
      );
    }
  }
}
