import 'package:meta/meta.dart';

/// Github file diff.
@immutable
class GithubFileDiff {
  /// create an [GithubFileDiff].
  const GithubFileDiff(this.sha, this.filename, {this.patch});

  /// sha of the file.
  final String sha;

  /// filename of the file relative to root dir.
  final String filename;

  /// patch of the file.
  final String patch;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GithubFileDiff &&
          runtimeType == other.runtimeType &&
          sha == other.sha &&
          filename == other.filename &&
          patch == other.patch;

  @override
  int get hashCode => sha.hashCode ^ filename.hashCode ^ patch.hashCode;

  @override
  String toString() {
    return 'GithubFileDiff{sha: $sha, filename: $filename, patch: $patch}';
  }
}
