import "package:meta/meta.dart" show visibleForTesting;

/// Dart lint violation class representation.
class StyleGuideViolation {
  /// Create a new [StyleGuideViolation].
  const StyleGuideViolation(
    this.severity,
    this.type,
    this.file,
    this.line,
    this.lineColumn,
    this.rule,
    this.ruleDescription,
  )   : assert(severity != null, "severity can't be null"),
        assert(type != null, "type can't be null"),
        assert(file != null, "file can't be null"),
        assert(line != null, "line can't be null"),
        assert(lineColumn != null, "lineColumn can't be null"),
        assert(rule != null, "rule can't be null"),
        assert(ruleDescription != null, "ruleDescription can't be null");

  /// Create a new [StyleGuideViolation] for an invalid lint violation.
  factory StyleGuideViolation.invalid(
    final String filePath,
  ) {
    return StyleGuideViolation(
      ViolationSeverity.withId("INVALID"),
      "",
      filePath,
      0,
      0,
      "",
      "is a part and cannot be analyzed.",
    );
  }

  /// Lint violation severity
  final ViolationSeverity severity;

  /// Type of lint violation.
  final String type;

  /// The lint rule that have been violated.
  final String rule;

  /// The lint rule description.
  final String ruleDescription;

  /// The file violating the lint rule.
  final String file;

  /// The file's line violating the lint rule.
  final int line;

  /// the file's line column violating the lint rule.
  final int lineColumn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleGuideViolation &&
          runtimeType == other.runtimeType &&
          severity == other.severity &&
          type == other.type &&
          rule == other.rule &&
          ruleDescription == other.ruleDescription &&
          file == other.file &&
          line == other.line &&
          lineColumn == other.lineColumn;

  @override
  int get hashCode =>
      severity.hashCode ^
      type.hashCode ^
      rule.hashCode ^
      ruleDescription.hashCode ^
      file.hashCode ^
      line.hashCode ^
      lineColumn.hashCode;

  @override
  String toString() {
    return "StyleGuideViolation{severity: $severity, type: $type, rule: $rule,"
        " ruleDescription: $ruleDescription, file: $file,"
        " line: $line, lineColumn: $lineColumn}";
  }
}

const ViolationSeverity _info = ViolationSeverity.private(0, "INFO");
const ViolationSeverity _warning = ViolationSeverity.private(1, "WARNING");
const ViolationSeverity _error = ViolationSeverity.private(2, "ERROR");
const ViolationSeverity _invalid = ViolationSeverity.private(3, "INVALID");

/// Dart lint violation severity.
class ViolationSeverity {
  /// Create [ViolationSeverity] with [level] and [id].
  @visibleForTesting
  const ViolationSeverity.private(this.level, this.id)
      : assert(level != null, "severity can't be null"),
        assert(id != null, "id can't be null");

  /// Create [ViolationSeverity] from the specified [id].
  ///
  /// Notes: the id need to be one of the items in [supportedSeverities].
  factory ViolationSeverity.withId(final String id) {
    final lintSeverity = supportedSeverities
        .firstWhere((element) => element.id == id, orElse: () => null);

    if (lintSeverity == null) {
      throw ArgumentError.value(
        id,
        "id",
        "only: ${supportedSeverities.map((item) => item.id)}",
      );
    } else {
      return lintSeverity;
    }
  }

  /// The level of severity of the style guide violation.
  final int level;

  /// The unique id of lint violation severity.
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViolationSeverity &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          id == other.id;

  @override
  int get hashCode => level.hashCode ^ id.hashCode;

  @override
  String toString() => "ViolationSeverity{level: $level, id: $id}";

  /// Contains the list of supported lint rules severities.
  static final List<ViolationSeverity> supportedSeverities = [
    _info,
    _warning,
    _error,
    _invalid
  ];
}
