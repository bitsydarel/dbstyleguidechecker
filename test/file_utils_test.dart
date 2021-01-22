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

import 'package:dbstyleguidechecker/src/utils/file_utils.dart';
import 'package:test/test.dart';

void main() {
  test(
    'should throw an assertion error is file is not from the projectDir',
    () {
      const String filePath =
          'dart_package_linter/lib/src/lint_violation_parser.dart';

      expect(
            () => getFileRelativePath(filePath, 'dbstyleguidechecker'),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    },
  );

  test('should return relative path to the directory', () {
    const String filePath =
        '/Users/darelbitsy/IdeaProjects/dbstyleguidechecker/lib/src/utils/file_utils.dart';

    const String projectDir = '/Users/darelbitsy/IdeaProjects/dbstyleguidechecker/';

    expect(
      getFileRelativePath(filePath, projectDir),
      'lib/src/utils/file_utils.dart',
    );
  });

  group(
    'test if file paths are the same',
        () {
      test(
        'should return true if paths are the same but are not fully specified',
            () {
          const String filePath1 =
              'lib/src/parsers/dart/dart_analyzer_violation_parser.dart';
          const String filePath2 = 'dart/dart_analyzer_violation_parser.dart';

          expect(
            isSameFilePath(filePath1, filePath2),
            completion(isTrue),
          );

          expect(
            isSameFilePath(filePath2, filePath1),
            completion(isTrue),
          );

          expect(
            isSameFilePath(
              'lib/src/code_style_violation.dart',
              'src/code_style_violation.dart',
            ),
            completion(isTrue),
          );

          expect(
            isSameFilePath(
              'src/code_style_violation.dart',
              'lib/src/code_style_violation.dart',
            ),
            completion(isTrue),
          );
        },
      );

      test('should return true if paths are identical', () {
        const String filePath1 = 'lib/src/utils/file_utils.dart';
        const String filePath2 = 'lib/src/utils/file_utils.dart';

        expect(
          isSameFilePath(filePath1, filePath2),
          completion(isTrue),
        );
      });

      test(
        'should return true if paths are equals '
            "even if they don't contains sub paths",
            () {
          const String filePath1 = 'file_utils.dart';
          const String filePath2 = 'file_utils.dart';

          expect(
            isSameFilePath(filePath1, filePath2),
            completion(isTrue),
          );
        },
      );

      test(
        'should return false if paths are not the same',
            () {
          expect(
            isSameFilePath('file_utils.dart', 'file_utils2.dart'),
            completion(isFalse),
          );

          expect(
            isSameFilePath(
              'lib/src/styleguidecheckreports/github/github_api_service.dart',
              'lib/src/styleguidecheckreports/github/github_file_diff.dart',
            ),
            completion(isFalse),
          );
        },
      );

      test(
        'should return false if paths are not the same',
            () {
          expect(
            isSameFilePath(
              'example/lib/example.dart',
              'test/file_utils_test.dart',
            ),
            completion(isFalse),
          );
        },
      );
    },
  );

  test('should return the patchLocation', () {
    const String patch = '''@@ -1,4 +1,6 @@
 import "package:dbpage_routing/dbpage_routing.dart";
 
 void main() {
+	print("random stup");
+	final unused_stuff = "dont worry";
 }''';

    expect(findViolationLineInFileDiff(patch, 5), completion(equals(5)));
  });
}
