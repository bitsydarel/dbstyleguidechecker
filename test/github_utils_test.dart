import 'package:dbstyleguidechecker/src/reporters/github/github_utils.dart';
import 'package:test/test.dart';

void main() {
  test('should return the repository owner if the path is valid', () {
    const String randomRepoUrl =
        'https://github.com/bitsydarel/fappconfiguration';
    const String randomRepoUrl2 = 'https://github.com/ardas/cx-android.git';

    expect(getGithubRepoOwner(randomRepoUrl), equals('bitsydarel'));
    expect(getGithubRepoOwner(randomRepoUrl2), equals('ardas'));
  });

  test('should return the repository name if the path is valid', () {
    const String randomRepoUrl =
        'https://github.com/bitsydarel/fappconfiguration';
    const String randomRepoUrl2 = 'https://github.com/ardas/cx-android.git';

    expect(getGithubRepoName(randomRepoUrl), equals('fappconfiguration'));
    expect(getGithubRepoName(randomRepoUrl2), equals('cx-android'));
  });
}
