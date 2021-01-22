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

import 'dart:convert';
import 'dart:io';

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/code_style_violation.dart';
import 'package:meta/meta.dart';

///
class JsonCodeStyleViolationReporter extends CodeStyleViolationsReporter {
  ///
  const JsonCodeStyleViolationReporter();

  @override
  Future<void> report(final List<CodeStyleViolation> violations) async {
    final Map<String, List<Map<String, Object>>> mapped =
        <String, List<Map<String, Object>>>{};

    _filterBySeverityAndUpdate(ViolationSeverity.info, violations, mapped);

    _filterBySeverityAndUpdate(ViolationSeverity.warning, violations, mapped);

    _filterBySeverityAndUpdate(ViolationSeverity.error, violations, mapped);

    _filterBySeverityAndUpdate(ViolationSeverity.invalid, violations, mapped);

    stdout.writeln(jsonEncode(mapped));
  }

  void _filterBySeverityAndUpdate(
    final ViolationSeverity severity,
    final List<CodeStyleViolation> violations,
    final Map<String, Object> json,
  ) {
    final List<Map<String, Object>> filtered = filterViolationBySeverity(
      severity,
      violations,
    );

    if (filtered.isNotEmpty) {
      json[severity.id] = filtered;
    }
  }

  ///
  @visibleForTesting
  List<Map<String, Object>> filterViolationBySeverity(
    final ViolationSeverity severity,
    final List<CodeStyleViolation> violations,
  ) {
    final List<Map<String, Object>> filtered = <Map<String, Object>>[];

    for (final CodeStyleViolation violation in violations) {
      if (severity == violation.severity) {
        filtered.add(violation.toJson());
      }
    }

    return filtered;
  }
}
