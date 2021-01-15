/// Get the github repository owner name from [repoUrl].
String getGithubRepoOwner(final String repoUrl) {
  final List<String> paths = Uri.parse(repoUrl).pathSegments;
  return paths[paths.length - 2];
}

/// Get the github repository name from [repoUrl].
String getGithubRepoName(final String repoUrl) {
  return Uri.parse(repoUrl).pathSegments.last.replaceAll('.git', '');
}
