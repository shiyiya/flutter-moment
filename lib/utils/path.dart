import 'dart:io';
import 'dart:io' as prefix0;

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:moment/utils/dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform/platform.dart';

Platform _platform = const LocalPlatform();

class MPath {
  static Future<String> getPicPath() async {
    return (await getExternalStorageDirectory()).path + '/Pictures/';
  }

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

    encoder.zipDirectory(Directory(dirPath),
        filename: (await getLocalDownloadPath()) + '/$outName');
  }

  static Future<bool> getStoragePermission(
      {BuildContext c, String failText}) async {
    final status =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (status[PermissionGroup.storage] == PermissionStatus.granted) {
      return true;
    }

    showAlertDialog(c, content: Text(failText), hideCancel: true);
    return false;
  }
}
