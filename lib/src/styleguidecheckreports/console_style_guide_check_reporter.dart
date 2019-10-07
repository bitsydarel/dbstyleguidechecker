import "package:dbstyleguidechecker/dbstyleguidechecker.dart";
import "package:dbstyleguidechecker/src/style_guide_violation.dart";
import "package:io/ansi.dart";

/// Create a [DBStyleGuideCheckReporter] that report violation to the console.
class ConsoleStyleGuideCheckReporter extends DBStyleGuideCheckReporter {
  /// Create a constant instance of the [ConsoleStyleGuideCheckReporter].
  const ConsoleStyleGuideCheckReporter();

  @override
  Future report(List<StyleGuideViolation> violations) async {
    for (final violation in violations) {
      print(
        yellow.wrap(
          "${violation.severity.id}|"
          "${violation.type}|"
          "${violation.rule}|"
          "${violation.ruleDescription}|"
          "${violation.file}|"
          "${violation.line}",
        ),
      );
    }
  }
}
