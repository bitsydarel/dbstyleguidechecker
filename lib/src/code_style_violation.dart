/*
 * BSD 3-Clause License
 *
 * Copyright (c) 2020, Bitsy Darel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'package:meta/meta.dart' show visibleForTesting, immutable, required;

// ignore_for_file: avoid_as

/// Dart lint violation class representation.
@immutable
class CodeStyleViolation {
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

  /// Create a new [CodeStyleViolation].
  const CodeStyleViolation({
    @required this.severity,
    @required this.type,
    @required this.file,
    @required this.line,
    @required this.lineColumn,
    @required this.rule,
    @required this.ruleDescription,
  })  : assert(severity != null, "severity can't be null"),
        assert(type != null, "type can't be null"),
        assert(file != null, "file can't be null"),
        assert(line != null, "line can't be null"),
        assert(lineColumn != null, "lineColumn can't be null"),
        assert(rule != null, "rule can't be null"),
        assert(ruleDescription != null, "ruleDescription can't be null");

  ///
  CodeStyleViolation.fromJson(final Map<String, Object> json)
      : type = json['type'] as String,
        file = json['file'] as String,
        line = json['line'] as int,
        lineColumn = json['lineColumn'] as int,
        rule = json['rule'] as String,
        ruleDescription = json['ruleDescription'] as String,
        severity = ViolationSeverity.fromMap(
          json['severity'] as Map<String, Object>,
        );

  ///
  Map<String, Object> toJson() {
    return <String, Object>{
      'type': type,
      'file': file,
      'line': line,
      'lineColumn': lineColumn,
      'rule': rule,
      'ruleDescription': ruleDescription,
      'severity': severity.toJson(),
    };
  }

  /// Create a new [CodeStyleViolation] for an invalid lint violation.
  factory CodeStyleViolation.invalid(
    final String filePath,
  ) {
    return CodeStyleViolation(
      severity: ViolationSeverity.withId('INVALID'),
      type: '',
      file: filePath,
      line: 0,
      lineColumn: 0,
      rule: '',
      ruleDescription: 'is a part and cannot be analyzed.',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CodeStyleViolation &&
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
    return 'StyleGuideViolation{severity: $severity, type: $type, rule: $rule,'
        ' ruleDescription: $ruleDescription, file: $file, '
        'line: $line, lineColumn: $lineColumn}';
  }
}

/// Lint violation severity.
@immutable
class ViolationSeverity {
  /// Violation severity of level info, meaning it's just a suggestions.
  static const ViolationSeverity info = ViolationSeverity.private(0, 'INFO');

  /// Violation severity of level warning, meaning it's might be an issue
  /// Should be resolved or explicitly ignored.
  static const ViolationSeverity warning =
      ViolationSeverity.private(1, 'WARNING');

  /// Violation severity of level error, meaning it's should be resolved asap.
  static const ViolationSeverity error = ViolationSeverity.private(2, 'ERROR');

  /// Violation severity of level invalid, meaning we don't know the severity.
  static const ViolationSeverity invalid =
      ViolationSeverity.private(3, 'INVALID');

  /// The level of severity of the style guide violation.
  final int level;

  /// The unique id of lint violation severity.
  final String id;

  /// Create [ViolationSeverity] from the parameter [json].
  ViolationSeverity.fromMap(final Map<String, Object> json)
      : level = json['level'] as int,
        id = json['id'] as String;

  /// Transform [ViolationSeverity] to a [Map].
  Map<String, Object> toJson() {
    return <String, Object>{'level': level, 'id': id};
  }

  /// Create [ViolationSeverity] with [level] and [id].
  @visibleForTesting
  const ViolationSeverity.private(this.level, this.id)
      : assert(level != null, "severity can't be null"),
        assert(id != null, "id can't be null");

  /// Create [ViolationSeverity] from the specified [id].
  ///
  /// Notes: the id need to be one of the items in [supportedSeverities].
  factory ViolationSeverity.withId(final String id) {
    final ViolationSeverity lintSeverity = supportedSeverities.firstWhere(
          (ViolationSeverity element) => element.id == id,
      orElse: () => null,
    );

    if (lintSeverity == null) {
      throw ArgumentError.value(
        id,
        'id',
        'only: ${supportedSeverities.map((ViolationSeverity item) => item.id)}',
      );
    } else {
      return lintSeverity;
    }
  }

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
  String toString() => 'ViolationSeverity{level: $level, id: $id}';

  /// Contains the list of supported lint rules severities.
  static final List<ViolationSeverity> supportedSeverities =
  <ViolationSeverity>[info, warning, error, invalid];
}
