import 'dart:io';
import 'dart:io' as prefix0;
import 'package:platform/platform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

Platform _platform = const LocalPlatform();

class MPath {
  static Future<String> getLocalDownloadPath() async {
    prefix0.Directory dir = _platform.isAndroid
        ? (await getExternalStorageDirectory())
        : (await getApplicationSupportDirectory());

    String dirPath;

    if (_platform.isAndroid) {
      bool hasExisted = await dir.exists();
      if (!hasExisted) {
        dir.create();
      }

      dirPath = dir.parent.parent.parent.parent.path + '/Download';
    } else {
      dirPath = dir.path;
    }

    return dirPath;
  }

  static encodeDirFile2Download(dirPath, outName) async {
    var encoder = ZipFileEncoder();

    encoder.zipDirectory(
        Directory(dirPath),
        filename: (await getLocalDownloadPath()) + '/$outName');
  }
}
