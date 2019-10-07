/// Process exit code for invalid command line argument.
const int exitInvalidArgument = 5;

/// Process exit code for missing required command line argument.
const int exitMissingRequiredArgument = 6;

/// Process exit code when flutter packages get or pub get failed.
const int exitPackageUpdatedFailed = 14;

/// Process exit code when parsing violations failed.
const int exitParsingViolationFailed = 19;

/// Process exit code when an unexpected error occurred.
const int exitUnexpectedError = 25;

/// Process exit because of github server api error.
const int exitGithubApiError = 26;

/// Process exit because file diff parsing error.
const int exitFileDiffParsingError = 27;

/// A class that represent a exception that can't be recovered.
class UnrecoverableException implements Exception {
  /// create a instance of the [UnrecoverableException].
  ///
  /// [reason] why this exception was created.
  const UnrecoverableException(this.reason, this.exitCode);

  /// the reason why we can recover from this exception.
  final String reason;

  /// The exit code of the process.
  final int exitCode;

  @override
  String toString() => "$reason";
}
