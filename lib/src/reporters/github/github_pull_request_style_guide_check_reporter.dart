import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/reporters/github/github_api_service.dart';
import 'package:dbstyleguidechecker/src/reporters/github/github_file_diff.dart';
import 'package:dbstyleguidechecker/src/style_guide_violation.dart';
import 'package:dbstyleguidechecker/src/utils/file_utils.dart';

/// Github pull request style guide check reporter.
class GithubPullRequestStyleGuideCheckReporter
    extends CodeStylesViolationsReporter {
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
      final String latestCommitId = await _service.getLatestCommitId(
        pullRequestId,
      );

      final List<GithubFileDiff> diffFiles = await _service.getPullRequestFiles(
        pullRequestId,
      );

      for (final CodeStyleViolation violation in violations) {
        // Find the file where the violation happened.
        final GithubFileDiff fileDiff = await _firstMatching(
          violation,
          diffFiles,
        );

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

      if (pullRequestNeedFixes) {
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

  Future<GithubFileDiff> _firstMatching(
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
