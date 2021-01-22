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

import 'package:dbstyleguidechecker/src/exceptions.dart';
import 'package:dbstyleguidechecker/src/reporters/github/github_file_diff.dart';
import 'package:dbstyleguidechecker/src/code_style_violation.dart';
import 'package:dbstyleguidechecker/src/utils/file_utils.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart' show visibleForTesting;

/// Github api service.
class GithubApiService {
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

  /// Create a new [GithubApiService].
  GithubApiService(this.repoOwner,
      this.repoName,
      this.apiToken, [
        this.baseUrl = 'https://api.github.com',
      ]) : headers = <String, String>{
    'Accept': 'application/vnd.github.v3+json',
    'Authorization': 'token $apiToken'
  };

  /// Verify if pull request is open.
  Future<bool> isPullRequestOpen(final String pullRequestId) async {
    final http.Response response = await http.get(
      '$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId',
      headers: headers,
    );

    final Exception apiError = UnrecoverableException(
      'Could not verify if pull request is still open: ${response.body}',
      exitGithubApiError,
    );

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is Map<String, dynamic>) {
        return jsonResponse['state'] == 'open';
      } else {
        throw apiError;
      }
    } else {
      throw apiError;
    }
  }

  /// Add a review comment to the github pull request.
  Future<void> addReviewComment(final String pullRequestId,
      final CodeStyleViolation violation,
      final GithubFileDiff fileDiff,
      final String commitId,) async {
    final int violationLineInDiff = await findViolationLineInFileDiff(
      fileDiff?.patch,
      violation.line,
    );

    final Map<String, dynamic> reviewComment = <String, dynamic>{
      'path': fileDiff.filename,
      'line': violation.line,
      'position': violationLineInDiff,
      'commit_id': commitId,
      'body': formatViolationMessage(violation)
    };

    final http.Response response = await http.post(
      '$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/comments',
      headers: headers,
      body: json.encode(reviewComment),
    );

    if (response.statusCode != 201) {
      throw UnrecoverableException(
        'Could not add review comment: ${response.body}',
        exitGithubApiError,
      );
    }
  }

  /// Require code changes.
  Future<void> requestChanges(final String commitId,
      final String pullRequestId,) async {
    final Map<String, dynamic> reviewStatus = <String, dynamic>{
      'commit_id': commitId,
      'event': 'REQUEST_CHANGES',
      'body': 'Your pull request seems to contains some '
          'code style guide violation, please verify them'
    };

    final http.Response response = await http.post(
      '$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/reviews',
      headers: headers,
      body: json.encode(reviewStatus),
    );

    if (response.statusCode != 200) {
      throw UnrecoverableException(
        'Could not add review comment: ${response.body}',
        exitGithubApiError,
      );
    }
  }

  /// Notify github that the pull request meet the project code style.
  Future<void> onCodeStyleViolationNotFound(final String commitId,
      final String pullRequestId,) async {
    final Map<String, dynamic> reviewStatus = <String, dynamic>{
      'commit_id': commitId,
      'body':
      'This is close to perfect! Waiting for someone to review and merge',
    };

    final http.Response response = await http.post(
      '$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/reviews',
      headers: headers,
      body: json.encode(reviewStatus),
    );

    if (response.statusCode != 200) {
      throw UnrecoverableException(
        'Could not add review comment: ${response.body}',
        exitGithubApiError,
      );
    }
  }

  /// Get the files included in a pull request.
  Future<List<GithubFileDiff>> getPullRequestFiles(final String pullRequestId,) async {
    final http.Response response = await http.get(
      '$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/files',
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<GithubFileDiff> diffFiles = <GithubFileDiff>[];

      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is List<dynamic>) {
        jsonResponse.whereType<Map<String, dynamic>>().forEach(
              (Map<String, dynamic> file) {
            final Object sha = file['sha'];
            final Object fileName = file['filename'];
            final Object patch = file['patch'];

            diffFiles.add(
              GithubFileDiff(
                sha is String ? sha : '',
                fileName is String ? fileName : '',
                patch: patch is String ? patch : null,
              ),
            );
          },
        );
      }

      return diffFiles;
    } else {
      throw UnrecoverableException(
        'Could not get pull request files: ${response.body}',
        exitGithubApiError,
      );
    }
  }

  /// Get the latest commit available on the pull request.
  Future<String> getLatestCommitId(final String pullRequestId) async {
    final http.Response response = await http.get(
      '$baseUrl/repos/$repoOwner/$repoName/pulls/$pullRequestId/commits',
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);

      if (jsonResponse is List<dynamic>) {
        final Map<String, dynamic> lastCommit =
            jsonResponse.whereType<Map<String, dynamic>>().last;

        final dynamic lastCommitId = lastCommit['sha'];

        if (lastCommitId is String) {
          return lastCommitId;
        }
      }

      return null;
    } else {
      throw UnrecoverableException(
        'Could not get pull request latest commit: ${response.body}',
        exitGithubApiError,
      );
    }
  }

  /// Format the [CodeStyleViolation].
  @visibleForTesting
  String formatViolationMessage(CodeStyleViolation violation) {
    final StringBuffer template = StringBuffer()
      ..writeln(violation.ruleDescription)..writeln('**SEVERITY**: ${violation.severity.id}')..writeln('**RULE**: ${violation.rule}')..writeln('**FILE**: ${violation.file}')..writeln('**LINE**: ${violation.line}');

    return template.toString();
  }
}
