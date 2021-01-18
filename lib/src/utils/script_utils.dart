import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/exceptions.dart';
import 'package:dbstyleguidechecker/src/utils/file_utils.dart';
import 'package:io/ansi.dart';
import 'package:meta/meta.dart';

const String _codeStyleParameter = 'code-style';
const String _projectTypeParameter = 'project-type';

const String _vcsUrlParameter = 'vcs-url';
const String _vcsPullRequestIdParameter = 'vcs-pull-request-id';
const String _vcsAccessTokenParameter = 'vcs-access-token';

/// Script parameter used to print help.
const String helpParameter = 'help';

const String _reporterTypeParameter = 'reporter-type';
const String _reporterOutputFileParameter = 'reporter-output-file';

/// Script parameter used for the [_reporterTypeParameter] parameter to specify
/// code violation reporter that will print violations to the console.
const String reporterOfTypeConsole = 'console';

/// Script parameter used for the [_reporterTypeParameter] parameter to specify
/// code violation reporter that will print violations to a file
/// specified by [_reporterOutputFileParameter].
const String reporterOfTypeFile = 'file';

/// Script parameter used for the [_reporterTypeParameter] parameter to specify
/// code violation reporter that will print violations to a github pull request.
///
/// This reporter require the following parameter to be specified:
/// [_vcsUrlParameter],[_vcsPullRequestIdParameter], [_vcsAccessTokenParameter].
const String reporterOfTypeGithub = 'github';

const List<String> _supportedReporterType = <String>[
  reporterOfTypeConsole,
  reporterOfTypeFile,
  reporterOfTypeGithub,
];

/// Script parameter used for [_projectTypeParameter] parameter to specify
/// that the script is run on a dart project.
const String dartProjectType = 'dart';

/// Script parameter used for [_projectTypeParameter] parameter to specify
/// that the script is run on a flutter project.
const String flutterProjectType = 'flutter';

/// List of project type supported by the script.
const List<String> supportedProjectType = <String>[
  dartProjectType,
  flutterProjectType,
];

/// DBStyleGuideChecker script argument parser.
final ArgParser argumentParser = ArgParser()
  ..addOption(
    _codeStyleParameter,
    defaultsTo: 'analysis_options.yaml',
    help: 'Specify the code style guide to use',
  )
  ..addOption(
    _projectTypeParameter,
    defaultsTo: dartProjectType,
    allowed: supportedProjectType,
    allowedHelp: <String, String>{
      dartProjectType: 'Report code style violation for dart project',
      flutterProjectType: 'Report code style violation for flutter project',
    },
    help: 'Specify the type of project to analyze',
  )
  ..addOption(
    _reporterTypeParameter,
    defaultsTo: reporterOfTypeConsole,
    allowed: _supportedReporterType,
    allowedHelp: <String, String>{
      reporterOfTypeConsole: 'Report code style violation to the console',
      reporterOfTypeFile: 'Report code style violation to a file',
      reporterOfTypeGithub: 'Report code style violation to github pull request'
    },
    help: 'Specify how to report code style violations',
  )
  ..addOption(
    _reporterOutputFileParameter,
    help: 'Specify the file where the file code violation reporter will output',
  )
  ..addOption(
    _vcsUrlParameter,
    help: 'VCS repository to push code style violation report',
  )
  ..addOption(
    _vcsPullRequestIdParameter,
    help: 'VCS repository pull request id',
  )
  ..addOption(
    _vcsAccessTokenParameter,
    help: 'VCS repository access token',
  )
  ..addFlag(
    helpParameter,
    help: 'print help message',
  );

/// Print help message to the console.
void printHelpMessage([final String message]) {
  if (message != null) {
    // ignore: avoid_print
    print(red.wrap('$message\n'));
  }

  final String options =
      LineSplitter.split(argumentParser.usage).map((String l) => l).join('\n');

  // ignore: avoid_print
  print(
    'Usage: dbstyleguidechecker --style-guide '
    '<path to analysis_options.yaml> <local project directory>'
    '\nOptions:\n$options',
  );
}

/// VCS Argument provided to the script by the user.
///
/// Values defined in this class are used by some [CodeStylesViolationsReporter]
/// to report code violations to a specific pull request.
class VcsArgument {
  /// VCS repository url.
  final String repoUrl;

  /// VCS pull request id.
  final String pullRequestId;

  /// VCS access token, that provide authorization to report code violation
  /// to the specified pull request [pullRequestId].
  final String accessToken;

  ///
  const VcsArgument({
    @required this.repoUrl,
    @required this.pullRequestId,
    @required this.accessToken,
  })  : assert(repoUrl != null, 'Repository url should be specified'),
        assert(pullRequestId != null, 'Pull request id should be specified'),
        assert(
          accessToken != null,
          'Repository Access Token should be specified',
        );

  /// Create a [VcsArgument] from the provided [argResults].
  factory VcsArgument.from(final ArgResults argResults) {
    final String repoUrl = _parseRepoUrlParameter(argResults);
    final String pullRequestId = _parsePullRequestIdParameter(argResults);
    final String accessToken = _parseAccessTokenParameter(argResults);

    return VcsArgument(
      repoUrl: repoUrl,
      pullRequestId: pullRequestId,
      accessToken: accessToken,
    );
  }

  static String _parseRepoUrlParameter(final ArgResults argResults) {
    final dynamic vcsUrl = argResults[_vcsUrlParameter];

    if (vcsUrl is String && vcsUrl.isNotEmpty) {
      return vcsUrl;
    } else {
      throw const UnrecoverableException(
        '$_vcsUrlParameter is not specified',
        exitMissingRequiredArgument,
      );
    }
  }

  static String _parsePullRequestIdParameter(final ArgResults argResults) {
    final dynamic pullRequestId = argResults[_vcsPullRequestIdParameter];

    if (pullRequestId is String && pullRequestId.isNotEmpty) {
      return pullRequestId;
    } else {
      throw const UnrecoverableException(
        '$_vcsPullRequestIdParameter is not specified',
        exitMissingRequiredArgument,
      );
    }
  }

  static String _parseAccessTokenParameter(final ArgResults argResults) {
    final dynamic vcsAccessToken = argResults[_vcsAccessTokenParameter];

    if (vcsAccessToken is String && vcsAccessToken.isNotEmpty) {
      return vcsAccessToken;
    } else {
      throw const UnrecoverableException(
        '$_vcsAccessTokenParameter is not specified',
        exitMissingRequiredArgument,
      );
    }
  }
}

/// DBStyleGuideChecker script arguments.
///
/// Contains all the argument supported by the script.
class ScriptArgument {
  /// Project directory where the style checker will be executed.
  final Directory projectDir;

  /// Code style that the checker will use to check for violations.
  final File codeStyle;

  /// Type of project the script is running against.
  final String projectType;

  /// Type of reporter to use.
  ///
  /// The value match one of the child of [CodeStylesViolationsReporter].
  final String reporterType;

  /// Output file where the [CodeStylesViolationsReporter]
  /// should report founded code style violations if supported by the reporter.
  final File reporterOutputFile;

  /// VCS configuration to be use by the [CodeStylesViolationsReporter]
  /// to report code violations issues.
  final VcsArgument vcs;

  ///
  const ScriptArgument({
    @required this.projectType,
    @required this.projectDir,
    @required this.codeStyle,
    this.reporterType,
    this.reporterOutputFile,
    this.vcs,
  })  : assert(projectDir != null, 'Project Dir should be specified'),
        assert(codeStyle != null, 'Code style should be specified'),
        assert(projectType != null, 'Project Type should be specified');

  /// Create a [ScriptArgument] from the provided [argResults].
  factory ScriptArgument.from(final ArgResults argResults) {
    final String projectType = _parseProjectType(argResults);

    final Directory projectDir = _parseProjectDirParameter(argResults);

    final File codeStyle = _parseCodeStyleParameter(projectDir, argResults);

    final String reporterType = _parseReporterType(argResults);

    final File reporterOutputFile = _parseReporterOutputFile(
      argResults,
      projectDir,
    );

    final VcsArgument vcs = _parseVcsParameter(argResults);

    return ScriptArgument(
      projectType: projectType,
      projectDir: projectDir,
      codeStyle: codeStyle,
      reporterType: reporterType,
      reporterOutputFile: reporterOutputFile,
      vcs: vcs,
    );
  }

  static String _parseProjectType(final ArgResults argResults) {
    if (!argResults.wasParsed(_projectTypeParameter)) {
      throw const UnrecoverableException(
        '$_projectTypeParameter parameter is required',
        exitMissingRequiredArgument,
      );
    }

    final dynamic projectType = argResults[_projectTypeParameter];

    if (projectType is String &&
        projectType.isNotEmpty &&
        supportedProjectType.contains(projectType)) {
      return projectType;
    } else {
      throw UnrecoverableException(
        '$_projectTypeParameter parameter is required, '
        "supported values are ${supportedProjectType.join(", ")}",
        exitMissingRequiredArgument,
      );
    }
  }

  static Directory _parseProjectDirParameter(final ArgResults argResults) {
    if (argResults.rest.length != 1) {
      throw const UnrecoverableException(
        'invalid project dir path',
        exitInvalidArgument,
      );
    }

    final Directory projectDir = getResolvedProjectDir(argResults.rest[0]);

    if (!projectDir.existsSync()) {
      throw const UnrecoverableException(
        'specified local project dir does not exist',
        exitInvalidArgument,
      );
    }

    return projectDir;
  }

  static File _parseCodeStyleParameter(
    final Directory projectDir,
    final ArgResults argResults,
  ) {
    File codeStyleFile;

    final dynamic codeStyleFilePath = argResults[_codeStyleParameter];

    if (codeStyleFilePath is String && codeStyleFilePath.isNotEmpty) {
      codeStyleFile = getFile(
        codeStyleFilePath,
        projectDir.path,
      );
    }

    if (codeStyleFile == null || !codeStyleFile.existsSync()) {
      throw const UnrecoverableException(
        'specified $_codeStyleParameter parameter file does not exist',
        exitInvalidArgument,
      );
    }

    return codeStyleFile;
  }

  static String _parseReporterType(final ArgResults argResults) {
    final dynamic reporterType = argResults[_reporterTypeParameter];

    if (reporterType is String &&
        reporterType.isNotEmpty &&
        _supportedReporterType.contains(reporterType)) {
      return reporterType;
    } else {
      throw const UnrecoverableException(
        'Invalid $_reporterTypeParameter provided or not supported',
        exitInvalidArgument,
      );
    }
  }

  static File _parseReporterOutputFile(
    final ArgResults argResults,
    final Directory projectDir,
  ) {
    File outputFile;
    final dynamic outputFilePath = argResults[_reporterOutputFileParameter];

    if (outputFilePath == null) {
      return null;
    }

    if (outputFilePath is String && outputFilePath.isNotEmpty) {
      outputFile = getFile(outputFilePath, projectDir.path);
    }

    if (outputFile == null) {
      throw const UnrecoverableException(
        'specified $_reporterOutputFileParameter parameter file does not exist',
        exitInvalidArgument,
      );
    }

    return outputFile;
  }

  static VcsArgument _parseVcsParameter(final ArgResults argResults) {
    final bool urlProvided = argResults.wasParsed(_vcsUrlParameter);

    final bool pullRequestIdProvided = argResults.wasParsed(
      _vcsPullRequestIdParameter,
    );

    final bool accessTokenProvided = argResults.wasParsed(
      _vcsAccessTokenParameter,
    );

    if (!urlProvided && !pullRequestIdProvided && !accessTokenProvided) {
      return null;
    } else {
      return VcsArgument.from(argResults);
    }
  }
}
