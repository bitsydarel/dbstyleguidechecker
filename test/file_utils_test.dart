import 'dart:io';

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
              'lib/src/style_guide_violation.dart',
              'src/style_guide_violation.dart',
            ),
            completion(isTrue),
          );

          expect(
            isSameFilePath(
              'src/style_guide_violation.dart',
              'lib/src/style_guide_violation.dart',
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
          Directory.current = '../dbpage_routing/example';

          expect(
            isSameFilePath(
              'example/lib/dbpage_routing_example.dart',
              'test/posts_page_path_test.dart',
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
