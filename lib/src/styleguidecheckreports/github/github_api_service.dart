import "dart:convert";

import "package:dbstyleguidechecker/src/expections.dart";
import "package:dbstyleguidechecker/src/style_guide_violation.dart";
import "package:dbstyleguidechecker/src/styleguidecheckreports/github/github_file_diff.dart";
import "package:dbstyleguidechecker/src/utils/file_utils.dart";
import "package:http/http.dart" as http;
import "package:meta/meta.dart" show visibleForTesting;

/// Github api service.
class GithubApiService {
  /// Create a new [GithubApiService].
  GithubApiService(
    this.repoOwner,
    this.repoName,
    this.apiToken, [
    this.baseUrl = "https://api.github.com",
  ]) : headers = {
          "Accept": "application/vnd.github.v3+json",
          "Authorization": "token $apiToken"
        };

  /// Github repository name;
  final String repoName;

  /// Github repository owner.
  final String repoOwner;

  /// Github api base url.
  final String baseUrl;

  /// Github api token.
  final String apiToken;

  /// The headers to apply to every api requests.
  final Map<String, String> headers;

  /// Verify if pull request is open.
  Future<bool> isPullRequestOpen(final int pullRequestId) async {
    final response = await http.get(
      "$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId",
      headers: headers,
    );

    print("Request url: ${response.request.url}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;

      return data["state"] == "open";
    } else {
      throw UnrecoverableException(
        "Could not verify if pull request is still open: ${response.body}",
        exitGithubApiError,
      );
    }
  }

  /// Add a review comment to the github pull request.
  Future<void> addReviewComment(
    final int pullRequestId,
    final StyleGuideViolation violation,
    final GithubFileDiff fileDiff,
    final String commitId,
  ) async {
    final violationLineInDiff = await findViolationLineInFileDiff(
      fileDiff?.patch,
      violation.line,
    );

    final reviewComment = <String, dynamic>{
      "path": fileDiff.filename,
      "line": violation.line,
      "position": violationLineInDiff,
      "commit_id": commitId,
      "body": formatViolationMessage(violation)
    };

    final response = await http.post(
      "$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/comments",
      headers: headers,
      body: json.encode(reviewComment),
    );

    if (response.statusCode != 201) {
      throw UnrecoverableException(
        "Could not add review comment: ${response.body}",
        exitGithubApiError,
      );
    }
  }

  /// Require code changes.
  Future<void> requestChanges(
    final String commitId,
    int pullRequestId,
  ) async {
    final reviewStatus = <String, dynamic>{
      "commit_id": commitId,
      "event": "REQUEST_CHANGES",
      "body": "Your pull request seems to contains some "
          "code style guide violation, please verify them"
    };

    final response = await http.post(
      "$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/reviews",
      headers: headers,
      body: json.encode(reviewStatus),
    );

    if (response.statusCode != 200) {
      throw UnrecoverableException(
        "Could not add review comment: ${response.body}",
        exitGithubApiError,
      );
    }
  }

  /// Notify github that the pull request meet the project style guide.
  Future<void> styleGuideCheckSucceeded(
    String commitId,
    int pullRequestId,
  ) async {
    final reviewStatus = <String, dynamic>{
      "commit_id": commitId,
      "body":
          "This is close to perfect! Waiting for someone to review and merge",
    };

    final response = await http.post(
      "$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/reviews",
      headers: headers,
      body: json.encode(reviewStatus),
    );

    if (response.statusCode != 200) {
      throw UnrecoverableException(
        "Could not add review comment: ${response.body}",
        exitGithubApiError,
      );
    }
  }

  /// Get the files included in a pull request.
  Future<List<GithubFileDiff>> getPullRequestFiles(
    final int pullRequestId,
  ) async {
    final response = await http.get(
      "$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/files",
      headers: headers,
    );

    if (response.statusCode == 200) {
      final diffFiles = <GithubFileDiff>[];

      final files = (json.decode(response.body) as List<dynamic>)
          .map((dynamic file) => file as Map<String, dynamic>);

      for (final file in files) {
        diffFiles.add(
          GithubFileDiff(
            file["sha"] as String,
            file["filename"] as String,
            file["patch"] as String,
          ),
        );
      }

      return diffFiles;
    } else {
      throw UnrecoverableException(
        "Could not get pull request files: ${response.body}",
        exitGithubApiError,
      );
    }
  }

  /// Get the latest commit available on the pull request.
  Future<String> getLatestCommitId(final int pullRequestId) async {
    final response = await http.get(
      "$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/commits",
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = (json.decode(response.body) as List<dynamic>)
          .map((dynamic commit) => commit as Map<String, dynamic>);

      return data.last["sha"] as String;
    } else {
      throw UnrecoverableException(
        "Could not get pull request latest commit: ${response.body}",
        exitGithubApiError,
      );
    }
  }

  /// Format the [StyleGuideViolation].
  @visibleForTesting
  String formatViolationMessage(StyleGuideViolation violation) {
    final template = StringBuffer()
      ..writeln(violation.ruleDescription)
      ..writeln("**SEVERITY**: ${violation.severity.id}")
      ..writeln("**RULE**: ${violation.rule}")
      ..writeln("**FILE**: ${violation.file}")
      ..writeln("**LINE**: ${violation.line}");

    return template.toString();
  }
}
