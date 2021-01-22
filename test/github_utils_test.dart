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
