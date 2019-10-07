import "package:dbstyleguidechecker/dbstyleguidelinter.dart";
import "package:dbstyleguidechecker/src/style_guide_violation.dart";
import "package:dbstyleguidechecker/src/styleguidecheckreports/github/github_api_service.dart";
import "package:dbstyleguidechecker/src/styleguidecheckreports/github/github_file_diff.dart";

/// Github pull request style guide check reporter.
class GithubPullRequestStyleGuideCheckReporter
    extends DBStyleGuideCheckReporter {
  /// Create a [GithubPullRequestStyleGuideCheckReporter].
  GithubPullRequestStyleGuideCheckReporter(
    this.repoOwner,
    this.repoName,
    this.pullRequestId,
    this.apiToken,
  ) : _apiService = GithubApiService(repoOwner, repoName, apiToken);

  /// Github api token to use for every requests.
  final String apiToken;

  /// Github project owner.
  final String repoOwner;

  /// Github project name.
  final String repoName;

  /// Github pull request id.
  final int pullRequestId;

  final GithubApiService _apiService;

  @override
  Future report(List<StyleGuideViolation> violations) async {
    if (await _apiService.isPullRequestOpen(pullRequestId)) {
      final latestCommitId = await _apiService.getLatestCommitId(pullRequestId);
      final diffFiles = await _apiService.getPullRequestFiles(pullRequestId);

      for (final violation in violations) {
        final fileDiff = await _firstMatching(violation, diffFiles);

        if (fileDiff == null) {
          continue;
        }

        await _apiService.addReviewComment(
          pullRequestId,
          violation,
          fileDiff,
          latestCommitId,
        );
      }

      if (violations.any((violation) => violation.severity.level > 0)) {
        await _apiService.requestChanges(latestCommitId, pullRequestId);
      } else {
        await _apiService.styleGuideCheckSucceeded(
          latestCommitId,
          pullRequestId,
        );
      }
    } else {
      throw UnrecoverableException(
        "github pull request with id $pullRequestId is already closed",
        exitGithubApiError,
      );
    }
  }

  Future<GithubFileDiff> _firstMatching(
    final StyleGuideViolation violation,
    final List<GithubFileDiff> fileDiffs,
  ) async {
    for (final fileDiff in fileDiffs) {
      if (await isSameFilePath(fileDiff.filename, violation.file)) {
        return fileDiff;
      }
    }
    return null;
  }
}
