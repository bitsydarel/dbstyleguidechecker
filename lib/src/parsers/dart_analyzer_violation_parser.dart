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

import 'dart:convert' show LineSplitter;

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/code_style_violation.dart';
import 'package:dbstyleguidechecker/src/utils/file_utils.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// Dart analyzer violation parser.
class DartAnalyzerViolationParser extends CodeStyleViolationsParser {
  /// Create an instance of dart analyzer violation parser.
  const DartAnalyzerViolationParser();

  /// The regular expression that parse a lint line parser.
  static final RegExp _regexp = RegExp(
    // ignore: prefer_interpolation_to_compose_strings
    '^' + // beginning of line
        r'([\w_\.]+)\|' * 3 + // first three error notes
        r'([^\|]+)\|' + // file path
        r'([\w_\.]+)\|' * 3 + // line, column, length
        '(.*?)' + // rest is the error message
        r'$', // end of line
  );

  @override
  Future<List<CodeStyleViolation>> parse(
    String violations,
    String projectDir,
  ) async {
    final List<CodeStyleViolation> parsedViolations = <CodeStyleViolation>[];

    for (final String violation in LineSplitter.split(violations)) {
      parsedViolations.add(
        parseStyleGuideViolation(violation, projectDir),
      );
    }

    return List<CodeStyleViolation>.unmodifiable(parsedViolations);
  }

  /// Parse a lint result line.
  ///
  /// [violation] to be parsed.
  ///
  /// [projectDir] containing this file.
  @visibleForTesting
  CodeStyleViolation parseStyleGuideViolation(
    final String violation, [
    String? projectDir,
  ]) {
    if (violation.isEmpty) {
      throw const UnrecoverableException(
        'violation check is empty',
        exitParsingViolationFailed,
      );
    }

    final Iterable<RegExpMatch> matches = _regexp.allMatches(violation);

    if (matches.isEmpty) {
      if (violation.endsWith('is a part and cannot be analyzed.')) {
        String filePath = violation.split(' ').first;

        if (projectDir != null) {
          filePath = getFileRelativePath(filePath, projectDir);
        }

        return CodeStyleViolation.invalid(filePath);
      }

      throw UnrecoverableException(
        'Does not match any of the expected value: $violation ',
        exitParsingViolationFailed,
      );
    } else {
      final RegExpMatch result = matches.single;

      // starting from one because it's the
      final ViolationSeverity severity = ViolationSeverity.withId(result[1]!);
      final String type = result[2]!;
      final String rule = result[3]!;

      String filePath = result[4]!;

      if (projectDir != null) {
        filePath = getFileRelativePath(filePath, projectDir);
      }

      final int lineNumber = int.parse(result[5]!);
      final int lineColumn = int.parse(result[6]!);
      final String lintRuleDescription = result[8]!;

      return CodeStyleViolation(
        severity: severity,
        type: type,
        file: filePath,
        line: lineNumber,
        lineColumn: lineColumn,
        rule: rule,
        ruleDescription: lintRuleDescription,
      );
    }
  }
}
