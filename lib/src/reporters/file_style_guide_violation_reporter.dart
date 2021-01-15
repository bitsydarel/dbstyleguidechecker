import 'dart:io';

import 'package:dbstyleguidechecker/dbstyleguidechecker.dart';
import 'package:dbstyleguidechecker/src/style_guide_violation.dart';

/// File [CodeStylesViolationsReporter]
class FileCodeStyleViolationsReporter extends CodeStylesViolationsReporter {
  /// File used to write the report to.
  final File file;

  /// Create a [CodeStylesViolationsReporter]
  /// that [CodeStyleViolation] to the specified [file].
  const FileCodeStyleViolationsReporter(this.file);

  @override
  Future<void> report(List<CodeStyleViolation> violations) async {
    final IOSink writer = file.openWrite(mode: FileMode.append);

    for (final CodeStyleViolation violation in violations) {
      writer.writeln(
        '${violation.severity.id}|'
        '${violation.type}|'
        '${violation.rule}|'
        '${violation.ruleDescription}|'
        '${violation.file}|'
        '${violation.line}',
      );
    }

    await writer.flush();

    await writer.close();
  }
}
