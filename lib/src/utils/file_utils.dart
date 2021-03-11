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
import 'dart:io';

import 'package:dbstyleguidechecker/src/exceptions.dart';
import 'package:path/path.dart' as path;

final RegExp _diffFinder = RegExp(
  r'^@@\s-(\d+),\d+\s\+(\d+),\d+\s@@',
);

/// Get the relative path of a file from it's parent directory.
String getFileRelativePath(final String filePath, final String projectDir) {
  assert(
    path.isWithin(projectDir, filePath),
    '$filePath is not from the $projectDir project.',
  );

  return path.relative(filePath, from: projectDir);
}

/// Check if the file paths are the or pointing to the same location.
Future<bool> isSameFilePath(
  final String filePath1,
  final String filePath2,
) async {
  // If file paths are identical let avoid unnecessary check.
  if (filePath1 == filePath2) {
    return true;
  }

  // get both paths segments.
  final List<String> file1Paths = Uri.parse(filePath1).pathSegments;
  final List<String> file2Paths = Uri.parse(filePath2).pathSegments;

  if (file1Paths.length == file2Paths.length) {
    // If they are the same length and one of them is empty
    // just return true
    return _compareSegmentWithSameLength(file1Paths, file2Paths);
  } else {
    if (file1Paths.length > file2Paths.length) {
      return _compareSegmentWithSameLength(
        file1Paths.sublist(file1Paths.length - file2Paths.length),
        file2Paths,
      );
    } else {
      return _compareSegmentWithSameLength(
        file2Paths.sublist(file2Paths.length - file1Paths.length),
        file1Paths,
      );
    }
  }
}

bool _compareSegmentWithSameLength(
  List<String> paths1,
  List<String> paths2,
) {
  if (paths1.isEmpty) {
    return true;
  }

  for (int index = 0; index < paths1.length; index++) {
    if (paths1[index] != paths2[index]) {
      return false;
    }
  }

  return true;
}

/// Find the violation [lineNumber] in the file diff [path].
Future<int> findViolationLineInFileDiff(
  final String? patch,
  final int lineNumber,
) async {
  if (patch == null || patch.isEmpty) {
    return 0;
  }

  int currentLine = -1;
  int patchLocation = 0;

  for (final String line in LineSplitter.split(patch)) {
    if (line.startsWith('@')) {
      final Iterable<RegExpMatch> matches = _diffFinder.allMatches(line);

      if (matches.isEmpty) {
        throw UnrecoverableException(
          'Unable to parse patch line $line\nFull patch: \n$patch',
          exitFileDiffParsingError,
        );
      }

      final RegExpMatch result = matches.single;

      currentLine = int.parse(result[1]!);
    } else if (line.startsWith('+') || line.startsWith(' ')) {
      // Added or unmodified
      if (currentLine == lineNumber) {
        return patchLocation;
      }
      currentLine++;
    }

    patchLocation++;
  }

  return 0;
}

/// Get the file from the [filePath] provided.
///
/// [projectDir] is only used, if the provided [filePath] is relative to the
/// [projectDir].
File getFile(final String filePath, final String projectDir) {
  final File fullPathFile = File(path.canonicalize(filePath));

  if (fullPathFile.existsSync()) {
    return fullPathFile;
  }

  final File fileFromCurrentDir = File(
    path.canonicalize(
      path.join(path.current, filePath),
    ),
  );

  if (fileFromCurrentDir.existsSync()) {
    return fileFromCurrentDir;
  }

  return fullPathFile;
}

/// Get the project [Directory] with a full path.
Directory getResolvedProjectDir(final String projectDir) {
  return Directory(path.canonicalize(projectDir));
}
