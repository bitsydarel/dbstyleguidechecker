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

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/reporters/github/github_api_service.dart';
import 'package:dbstyleguidechecker/src/reporters/github/github_file_diff.dart';
import 'package:dbstyleguidechecker/src/code_style_violation.dart';
import 'package:dbstyleguidechecker/src/utils/file_utils.dart';

/// Github pull request style guide check reporter.
class GithubPullRequestStyleGuideCheckReporter
    extends CodeStyleViolationsReporter {
  /// Create a [GithubPullRequestStyleGuideCheckReporter].
  GithubPullRequestStyleGuideCheckReporter(
    this.repoOwner,
    this.repoName,
    this.pullRequestId,
    this.apiToken,
  ) : _service = GithubApiService(repoOwner, repoName, apiToken);

  /// Github api token to use for every requests.
  final String apiToken;

  /// Github project owner.
  final String repoOwner;

  /// Github project name.
  final String repoName;

  /// Github pull request id.
  final String pullRequestId;

  final GithubApiService _service;

  @override
  Future<void> report(List<CodeStyleViolation> violations) async {
    if (await _service.isPullRequestOpen(pullRequestId)) {
      // Get the last commit id, so we can fetch the latest state of the code.
      final String? latestCommitId =
          await _service.getLatestCommitId(pullRequestId);

      final List<GithubFileDiff> diffFiles =
          await _service.getPullRequestFiles(pullRequestId);

      for (final CodeStyleViolation violation in violations) {
        // Find the file where the violation happened.
        final GithubFileDiff? fileDiff =
            await _firstMatching(violation, diffFiles);

        if (fileDiff == null) {
          continue;
        }

        // Notify pull request of the code style violation.
        await _service.addReviewComment(
          pullRequestId,
          violation,
          fileDiff,
          latestCommitId,
        );
      }

      final bool pullRequestNeedFixes = violations.any(
        (CodeStyleViolation violation) => violation.severity.level > 0,
      );

      if (latestCommitId == null) {
      } else if (pullRequestNeedFixes) {
        await _service.requestChanges(latestCommitId, pullRequestId);
      } else {
        await _service.onCodeStyleViolationNotFound(
          latestCommitId,
          pullRequestId,
        );
      }
    } else {
      throw UnrecoverableException(
        'github pull request with id $pullRequestId is already closed',
        exitGithubApiError,
      );
    }
  }

  Future<GithubFileDiff?> _firstMatching(
    final CodeStyleViolation violation,
    final List<GithubFileDiff> fileDiffs,
  ) async {
    for (final GithubFileDiff fileDiff in fileDiffs) {
      if (await isSameFilePath(fileDiff.filename, violation.file)) {
        return fileDiff;
      }
    }
    return null;
  }
}
