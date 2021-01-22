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
import 'package:meta/meta.dart' show protected;

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/exceptions.dart';

/// Dart project style guide linter.
class DartProjectStyleGuideChecker extends CodeStyleViolationsChecker {
  /// create a Dart code style guide linter.
  const DartProjectStyleGuideChecker(
    File styleGuide,
    Directory projectDir,
    CodeStyleViolationsParser parser,
    CodeStyleViolationsReporter reporter,
  ) : super(styleGuide, projectDir, parser, reporter);

  @override
  Future<String> getCodeStyleViolations() {
    return runPubGet().then(
          (_) => Process.run(
        'dartanalyzer',
        <String>[
          '--format',
          'machine',
          '--options',
          styleGuide.path,
          projectDir.path,
        ],
        runInShell: true,
        stdoutEncoding: utf8,
      ).then((ProcessResult processResult) {
        final String output = processResult.stdout.toString();

        return output.isEmpty ? processResult.stderr.toString() : output;
      }),
    );
  }

  /// Run the
  @protected
  Future<void> runPubGet() {
    return Process.run(
      'pub',
      <String>['get'],
      runInShell: true,
      stdoutEncoding: utf8,
    ).then<void>((ProcessResult result) {
      final String errorOutput = result.stderr.toString();

      if (errorOutput.isNotEmpty) {
        throw UnrecoverableException(
          'could not run pub get: $errorOutput',
          exitPackageUpdatedFailed,
        );
      }
      return;
    });
  }
}
