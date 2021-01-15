import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/style_guide_violation.dart';
import 'package:io/ansi.dart';

/// Create [CodeStylesViolationsReporter] that report violation to the console.
class ConsoleCodeStyleViolationsReporter extends CodeStylesViolationsReporter {
  /// Create a constant instance of the [ConsoleCodeStyleViolationsReporter].
  const ConsoleCodeStyleViolationsReporter();

  @override
  Future<void> report(List<CodeStyleViolation> violations) async {
    for (final CodeStyleViolation violation in violations) {
      // Print to the console
      // ignore: avoid_print
      print(
        yellow.wrap(
          '${violation.severity.id}|'
          '${violation.type}|'
          '${violation.rule}|'
          '${violation.ruleDescription}|'
          '${violation.file}|'
          '${violation.line}',
        ),
      );
    }
  }
}
