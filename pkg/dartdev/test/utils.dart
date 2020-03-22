// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

Timeout defaultTimeout = Timeout(Duration(seconds: 15));

TestProject project({String mainSrc}) => TestProject(mainSrc: mainSrc);

class TestProject {
  static String get defaultProjectName => 'dartdev_temp';

  Directory dir;

  String get dirPath => dir.path;

  String get name => defaultProjectName;

  String get relativeFilePath => 'lib/main.dart';

  TestProject({String mainSrc}) {
    dir = Directory.systemTemp.createTempSync('dartdev');
    if (mainSrc != null) {
      file(relativeFilePath, mainSrc);
    }
    file('pubspec.yaml', 'name: $name\ndev_dependencies:\n  test: any\n');
  }

  void file(String name, String contents) {
    var file = File(path.join(dir.path, name));
    file.parent.createSync();
    file.writeAsStringSync(contents);
  }

  void dispose() {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  ProcessResult runSync(
    String command,
    List<String> args, {
    String workingDir,
  }) {
    var arguments = [
      absolutePathToDartdevFile,
      command,
    ];

    if (args != null && args.isNotEmpty) {
      arguments.addAll(args);
    }

    return Process.runSync(
      Platform.resolvedExecutable,
      arguments,
      workingDirectory: workingDir ?? dir.path,
    );
  }

  String _sdkRootPath;

  /// Return the root of the SDK.
  String get sdkRootPath {
    if (_sdkRootPath == null) {
      // Assumes the script importing this one is somewhere under the SDK.
      String current = path.canonicalize(Platform.script.toFilePath());
      do {
        String tryDir = path.dirname(current);
        if (File(path.join(tryDir, 'pkg', 'dartdev', 'bin', 'dartdev.dart'))
            .existsSync()) {
          _sdkRootPath = tryDir;
          return _sdkRootPath;
        }
        current = tryDir;
      } while (path.dirname(current) != current);
      throw StateError('can not find SDK repository root');
    }
    return _sdkRootPath;
  }

  String get absolutePathToDartdevFile {
    return path.join(sdkRootPath, 'pkg', 'dartdev', 'bin', 'dartdev.dart');
  }

  String get absolutePathToAnalysisServerFile {
    return path.join(
        sdkRootPath, 'pkg', 'analysis_server', 'bin', 'server.dart');
  }

  File findFile(String name) {
    var file = File(path.join(dir.path, name));
    return file.existsSync() ? file : null;
  }
}