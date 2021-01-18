import 'dart:io';

import 'package:dbstyleguidechecker/src/exceptions.dart';
import 'package:dbstyleguidechecker/src/parsers/dart/dart_analyzer_violation_parser.dart';
import 'package:dbstyleguidechecker/src/style_guide_violation.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  const DartAnalyzerViolationParser violationParser =
      DartAnalyzerViolationParser();

  test(
    'should throw an argument error exception if provided lint line is empty',
    () {
      expect(
        () => violationParser.parseStyleGuideViolation(''),
        throwsA(const TypeMatcher<UnrecoverableException>()),
      );
    },
  );

  group(
    'parsing of INFO, WARNING, ERROR or unkown lint violation',
    () {
      test('should return lint violation with severity INFO', () {
        const String violation =
            "INFO|LINT|prefer_double_quotes|/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart|15|14|14|Prefer double quotes where they won't require escape sequences.";

        expect(
          violationParser.parseStyleGuideViolation(violation),
          const CodeStyleViolation(
            severity: ViolationSeverity.info,
            type: 'LINT',
            file:
                '/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart',
            line: 15,
            lineColumn: 14,
            rule: 'prefer_double_quotes',
            ruleDescription: 'Prefer double quotes where '
                "they won't require escape sequences.",
          ),
        );
      });

      test(
        'Should return lint violation with severity as WARNING',
        () {
          const String lintViolation =
              "WARNING|LINT|directives_ordering|/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart|6|1|27|Place 'dart:' imports before other imports.";

          expect(
            violationParser.parseStyleGuideViolation(lintViolation),
            const CodeStyleViolation(
              severity: ViolationSeverity.warning,
              type: 'LINT',
              file:
                  '/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart',
              line: 6,
              lineColumn: 1,
              rule: 'directives_ordering',
              ruleDescription: "Place 'dart:' imports before other imports.",
            ),
          );
        },
      );

      test(
        'Should return lint violation with severity as ERROR',
        () {
          const String lintViolation =
              'ERROR|LINT|public_member_api_docs|/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart|24|7|10|Document all public members.';

          expect(
            violationParser.parseStyleGuideViolation(lintViolation),
            const CodeStyleViolation(
              severity: ViolationSeverity.error,
              type: 'LINT',
              file:
                  '/Users/darelbitsy/IdeaProjects/flutter_playground/lib/main.dart',
              line: 24,
              lineColumn: 7,
              rule: 'public_member_api_docs',
              ruleDescription: 'Document all public members.',
            ),
          );
        },
      );

      test(
        "should return invalid violation if file a part and can't be analyzed",
        () {
          const String violation =
              'dart_package_linter/lib/src/lint_violation_parser.g.dart is a part and cannot be analyzed.';

          expect(
            violationParser.parseStyleGuideViolation(violation),
            CodeStyleViolation.invalid(
              'dart_package_linter/lib/src/lint_violation_parser.g.dart',
            ),
          );
        },
      );

      test(
        'should throw an argument error if provided with unknown part file',
        () {
          const String violation =
              'Please pass in a library that contains this part.';

          expect(
            () => violationParser.parseStyleGuideViolation(violation),
            throwsA(const TypeMatcher<UnrecoverableException>()),
          );
        },
      );
    },
  );

  test(
    'should parse the lint result and return a list of lint violations',
    () async {
      final String projectDir = path.context.current;

      final String lines = await _parseLintResultFile('dart_lint_report.log');

      final List<CodeStyleViolation> lintViolations =
          await violationParser.parse(lines, projectDir);

      expect(lintViolations, hasLength(equals(27)));

      expect(
        lintViolations.where(
          (CodeStyleViolation violation) =>
              violation.severity == ViolationSeverity.invalid,
        ),
        isEmpty,
      );
    },
  );

  test(
    'should parse the lint result and return a list of '
    'violations with one invalid violation',
    () async {
      final String projectDir = path.context.current;

      final String lines =
          await _parseLintResultFile('dart_lint_report_with_invalid_part.log');

      final List<CodeStyleViolation> lintViolations =
          await violationParser.parse(lines, projectDir);

      expect(lintViolations, hasLength(equals(27)));

      expect(
        lintViolations.where(
          (CodeStyleViolation violation) =>
              violation.severity == ViolationSeverity.invalid,
        ),
        isNotEmpty,
      );

      expect(
        lintViolations[5],
        CodeStyleViolation.invalid('lib/main.dart'),
      );
    },
  );
}

Future<String> _parseLintResultFile(final String filename) {
  final String projectDir = path.context.current;

  final String testResources = path.join(projectDir, 'test', 'resources');

  // ignore: avoid_slow_async_io
  return Directory(testResources).exists().then((bool directoryExist) {
    assert(
      directoryExist,
      'test resources does not exist under the path $testResources',
    );

    final File file = File('$testResources/$filename');

    return file.readAsString();
  });
}
