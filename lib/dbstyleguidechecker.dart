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

library dbstyleguidechecker;

import 'dart:io';
import 'package:meta/meta.dart' show protected;

import 'package:dbstyleguidechecker/src/code_style_violation.dart';

export 'package:dbstyleguidechecker/src/checkers/dart_project_style_guide_checker.dart';
export 'package:dbstyleguidechecker/src/checkers/flutter_project_style_guide_checker.dart';
export 'package:dbstyleguidechecker/src/reporters/console_code_style_violations_reporter.dart';
export 'package:dbstyleguidechecker/src/reporters/github/github_pull_request_style_guide_check_reporter.dart';
export 'package:dbstyleguidechecker/src/reporters/file_code_style_violation_reporter.dart';
export 'package:dbstyleguidechecker/src/parsers/dart_analyzer_violation_parser.dart';
export 'package:dbstyleguidechecker/src/exceptions.dart';
export 'package:dbstyleguidechecker/src/utils/script_utils.dart';
export 'package:dbstyleguidechecker/src/reporters/github/github_utils.dart';
export 'package:dbstyleguidechecker/src/reporters/json_code_style_violation_reporter.dart';

/// Code Style Violations Checker.
///
/// Check a coding style guide against a project.
abstract class CodeStyleViolationsChecker {
  /// style guide to verify.
  final File styleGuide;

  /// project directory containing the code.
  final Directory projectDir;

  /// Parse founded style check violations.
  final CodeStyleViolationsParser parser;

  /// Report founded style check violations.
  final CodeStyleViolationsReporter reporter;

  /// create a [CodeStyleViolationsChecker].
  ///
  /// [styleGuide] to use.
  ///
  /// [projectDir] to apply the [styleGuide] to.
  ///
  /// [parser] to parse founded style guide violations.
  ///
  /// [reporter] to report founded style guide violations.
  const CodeStyleViolationsChecker(this.styleGuide,
      this.projectDir,
      this.parser,
      this.reporter,);

  /// Run the checker.
  Future<void> check() async {
    final String unParsedViolations = await getCodeStyleViolations();

    final List<CodeStyleViolation> parsedViolations = await parser.parse(
      unParsedViolations,
      projectDir.path,
    );

    await reporter.report(parsedViolations);
  }

  /// Found [styleGuide] violations from the [projectDir].
  @protected
  Future<String> getCodeStyleViolations();
}

/// Code style violations reporter.
///
/// Report code style violations.
abstract class CodeStyleViolationsReporter {
  /// Create a constant instance of a [CodeStyleViolationsReporter].
  const CodeStyleViolationsReporter();

  /// Report [violations].
  Future<void> report(final List<CodeStyleViolation> violations);
}

/// Code style violations parser.
///
/// Parse founded violations.
abstract class CodeStyleViolationsParser {
  /// Create a constant instance of a [CodeStyleViolationsParser].
  const CodeStyleViolationsParser();

  /// Parse violations contained in the [violations].
  ///
  /// [projectDir] the violations are coming from.
  Future<List<CodeStyleViolation>> parse(final String violations,
      final String projectDir,);
}
