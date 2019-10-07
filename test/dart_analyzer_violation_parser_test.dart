import "dart:io";

import "package:dbstyleguidechecker/src/expections.dart";
import "package:dbstyleguidechecker/src/style_guide_violation.dart";
import "package:dbstyleguidechecker/src/styleguideviolationparsers/dart_analyzer_violation_parser.dart";
import "package:test/test.dart";
import "package:path/path.dart" as path;

void main() {
  final violationParser = const DartAnalyzerViolationParser();

  test(
    "should throw an argument error exception if provided lint line is empty",
    () {
      expect(
        () => violationParser.parseStyleGuideViolation(""),
        throwsA(const TypeMatcher<UnrecoverableException>()),
      );
    },
  );

  group(
    "parsing of INFO, WARNING, ERROR or unkown lint violation",
    () {
      test("should return lint violation with severity INFO", () {
        final violation =
            "INFO|LINT|prefer_double_quotes|/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart|15|14|14|Prefer double quotes where they won't require escape sequences.";

        expect(
          violationParser.parseStyleGuideViolation(violation),
          StyleGuideViolation(
            ViolationSeverity.withId("INFO"),
            "LINT",
            "/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart",
            15,
            14,
            "prefer_double_quotes",
            "Prefer double quotes where they won't require escape sequences.",
          ),
        );
      });

      test(
        "Should return lint violation with severity as WARNING",
        () {
          final lintViolation =
              "WARNING|LINT|directives_ordering|/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart|6|1|27|Place 'dart:' imports before other imports.";

          expect(
            violationParser.parseStyleGuideViolation(lintViolation),
            StyleGuideViolation(
              ViolationSeverity.withId("WARNING"),
              "LINT",
              "/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart",
              6,
              1,
              "directives_ordering",
              "Place 'dart:' imports before other imports.",
            ),
          );
        },
      );

      test(
        "Should return lint violation with severity as ERROR",
        () {
          final lintViolation =
              "ERROR|LINT|public_member_api_docs|/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart|24|7|10|Document all public members.";

          expect(
            violationParser.parseStyleGuideViolation(lintViolation),
            StyleGuideViolation(
              ViolationSeverity.withId("ERROR"),
              "LINT",
              "/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart",
              24,
              7,
              "public_member_api_docs",
              "Document all public members.",
            ),
          );
        },
      );

      test(
        "should return invalid violation if file a part and can't be analyzed",
        () {
          final violation =
              "dart_package_linter/lib/src/lint_violation_parser.g.dart is a part and cannot be analyzed.";

          expect(
            violationParser.parseStyleGuideViolation(violation),
            StyleGuideViolation.invalid(
              "dart_package_linter/lib/src/lint_violation_parser.g.dart",
            ),
          );
        },
      );

      test(
        "should throw an argument error if provided with unknown part file",
        () {
          final violation = "Please pass in a library that contains this part.";

          expect(
            () => violationParser.parseStyleGuideViolation(violation),
            throwsA(const TypeMatcher<UnrecoverableException>()),
          );
        },
      );
    },
  );

  test(
    "should parse the lint result and return a list of lint violations",
    () async {
      final projectDir = path.context.current;

      final lines = await _parseLintResultFile("lint_report.log");

      final lintViolations = await violationParser.parse(lines, projectDir);

      expect(lintViolations, hasLength(equals(27)));

      expect(
        lintViolations.where(
          (violation) =>
              violation.severity.id == "INVALID" ||
              violation.severity.level > 2,
        ),
        isEmpty,
      );
    },
  );

  test(
    // ignoring lint rule because test name should explain what's being tested.
    // ignore: lines_longer_than_80_chars
    "should parse the lint result and return a list of violations with one invalid violation",
    () async {
      final projectDir = path.context.current;

      final lines =
          await _parseLintResultFile("lint_report_with_invalid_part.log");

      final lintViolations = await violationParser.parse(lines, projectDir);

      expect(lintViolations, hasLength(equals(27)));

      expect(
        lintViolations.where(
          (violation) =>
              violation.severity.id == "INVALID" ||
              violation.severity.level > 2,
        ),
        isNotEmpty,
      );

      expect(
        lintViolations[5],
        StyleGuideViolation.invalid(
          "lib/main.dart",
        ),
      );
    },
  );
}

Future<String> _parseLintResultFile(final String filename) {
  final projectDir = path.context.current;

  final testResources = path.join(projectDir, "test", "resources");

  return Directory(testResources).exists().then((directoryExist) {
    assert(
      directoryExist,
      "test resources does not exist under the path $testResources",
    );

    final file = File("$testResources/$filename");

    return file.readAsString();
  });
}
