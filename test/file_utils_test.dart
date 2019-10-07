import "dart:io";

import "package:dbstyleguidechecker/src/utils/file_utils.dart";
import "package:test/test.dart";

void main() {
  test(
    "should throw an assertion error is file is not from the projectDir",
    () {
      final filePath = "dart_package_linter/lib/src/lint_violation_parser.dart";

      expect(
        () => getFileRelativePath(filePath, "dartlinter"),
        throwsA(const TypeMatcher<AssertionError>()),
      );
    },
  );

  test("should return relative path to the directory", () {
    final filePath =
        "/Users/darelbitsy/IdeaProjects/dartlinter/lib/src/utils/file_utils.dart";
    final projectDir = "/Users/darelbitsy/IdeaProjects/dartlinter/";

    expect(
      getFileRelativePath(filePath, projectDir),
      "lib/src/utils/file_utils.dart",
    );
  });

  test("should return the repository owner if the path is valid", () {
    final randomRepoUrl = "https://github.com/bitsydarel/fappconfiguration";
    final randomRepoUrl2 = "https://github.com/ardas/cx-android.git";

    expect(getGithubRepoOwner(randomRepoUrl), equals("bitsydarel"));
    expect(getGithubRepoOwner(randomRepoUrl2), equals("ardas"));
  });

  test("should return the repository name if the path is valid", () {
    final randomRepoUrl = "https://github.com/bitsydarel/fappconfiguration";
    final randomRepoUrl2 = "https://github.com/ardas/cx-android.git";

    expect(getGithubRepoName(randomRepoUrl), equals("fappconfiguration"));
    expect(getGithubRepoName(randomRepoUrl2), equals("cx-android"));
  });

  group(
    "test if file paths are the same",
    () {
      test(
        "should return true if paths are the same but are not fully specified",
        () {
          final filePath1 =
              "lib/src/styleguideviolationparsers/dart_analyzer_violation_parser.dart";
          final filePath2 =
              "styleguideviolationparsers/dart_analyzer_violation_parser.dart";

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
              "lib/src/style_guide_violation.dart",
              "src/style_guide_violation.dart",
            ),
            completion(isTrue),
          );

          expect(
            isSameFilePath(
              "src/style_guide_violation.dart",
              "lib/src/style_guide_violation.dart",
            ),
            completion(isTrue),
          );
        },
      );

      test("should return true if paths are identical", () {
        final filePath1 = "lib/src/utils/file_utils.dart";
        final filePath2 = "lib/src/utils/file_utils.dart";

        expect(
          isSameFilePath(filePath1, filePath2),
          completion(isTrue),
        );
      });

      test(
        // ignored because test is more clear with longer name.
        // ignore: lines_longer_than_80_chars
        "should return true if paths are equals even if they don't contains subpaths",
        () {
          final filePath1 = "file_utils.dart";
          final filePath2 = "file_utils.dart";

          expect(
            isSameFilePath(filePath1, filePath2),
            completion(isTrue),
          );
        },
      );

      test(
        "should return false if paths are not the same",
        () {
          expect(
            isSameFilePath("file_utils.dart", "file_utils2.dart"),
            completion(isFalse),
          );

          expect(
            isSameFilePath(
              "lib/src/styleguidecheckreports/github/github_api_service.dart",
              "lib/src/styleguidecheckreports/github/github_file_diff.dart",
            ),
            completion(isFalse),
          );
        },
      );

      test(
        "should return false if paths are not the same",
        () {
          Directory.current = "../dbpage_routing/example";

          expect(
            isSameFilePath(
              "example/lib/dbpage_routing_example.dart",
              "test/posts_page_path_test.dart",
            ),
            completion(isFalse),
          );
        },
      );
    },
  );

  test("should return the patchLocation", () {
    final patch = """@@ -1,4 +1,6 @@
 import "package:dbpage_routing/dbpage_routing.dart";
 
 void main() {
+	print("random stup");
+	final unused_stuff = "dont worry";
 }""";

    expect(findViolationLineInFileDiff(patch, 5), completion(equals(5)));
  });
}
