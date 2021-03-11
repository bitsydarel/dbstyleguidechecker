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

import 'package:meta/meta.dart' show visibleForTesting, immutable;

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
    required this.severity,
    required this.type,
    required this.file,
    required this.line,
    required this.lineColumn,
    required this.rule,
    required this.ruleDescription,
  });

  ///
  factory CodeStyleViolation.fromJson(final Map<String, Object> json) {
    final Object? type = json['type'];
    final Object? file = json['file'];
    final Object? line = json['line'];
    final Object? lineColumn = json['lineColumn'];
    final Object? rule = json['rule'];
    final Object? ruleDescription = json['ruleDescription'];
    final Object? severity = json['severity'];

    return CodeStyleViolation(
      type: type is String
          ? type
          : throw ArgumentError.value(type, 'type', 'invalid violation type'),
      file: file is String
          ? file
          : throw ArgumentError.value(type, 'file', 'invalid file path'),
      line: line is int
          ? line
          : throw ArgumentError.value(line, 'line', 'invalid line number'),
      lineColumn: lineColumn is int
          ? lineColumn
          : throw ArgumentError.value(
              lineColumn,
              'lineColumn',
              'invalid line column',
            ),
      rule: rule is String
          ? rule
          : throw ArgumentError.value(rule, 'rule', 'invalid rule name'),
      ruleDescription: ruleDescription is String
          ? ruleDescription
          : throw ArgumentError.value(
              ruleDescription,
              'ruleDescription',
              'invalid rule description',
            ),
      severity: severity is Map<String, Object>
          ? ViolationSeverity.fromMap(severity)
          : throw ArgumentError.value(
              severity,
              'severity',
              'is not a map of string to object',
            ),
    );
  }

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
  factory ViolationSeverity.fromMap(final Map<String, Object?> json) {
    final Object? level = json['level'];
    final Object? id = json['id'];

    return ViolationSeverity.private(
      level is int
          ? level
          : throw ArgumentError.value(level, 'level', 'invalid level'),
      id is String ? id : throw ArgumentError.value(id, 'id', 'invalid id'),
    );
  }

  /// Transform [ViolationSeverity] to a [Map].
  Map<String, Object> toJson() {
    return <String, Object>{'level': level, 'id': id};
  }

  /// Create [ViolationSeverity] with [level] and [id].
  @visibleForTesting
  const ViolationSeverity.private(this.level, this.id);

  /// Create [ViolationSeverity] from the specified [id].
  ///
  /// Notes: the id need to be one of the items in [supportedSeverities].
  factory ViolationSeverity.withId(final String id) {
    ViolationSeverity? lintSeverity;

    for (final ViolationSeverity severity in supportedSeverities) {
      if (severity.id == id) {
        lintSeverity = severity;
        break;
      }
    }

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
