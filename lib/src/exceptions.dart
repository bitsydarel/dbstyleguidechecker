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
  String toString() => 'Exit code: $exitCode, Reason: $reason';
}
