import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:retry/retry.dart';
import 'package:xml/xml.dart' as xml;

class WebDavException implements Exception {
  String cause;
  int statusCode;

  WebDavException(this.cause, this.statusCode);
}

class Client {
  String host;
  int port;
  String username;
  String password;
  String protocol = 'http';
  bool verifySsl = true;
  String path;
  String baseUrl;
  String cwd = "/";
  HttpClient httpClient = new HttpClient();

  /// Construct a new [Client].
  /// [path] will should be the root path you want to access.
  Client(String host, String username, String password, String path,
      {String protocol, int port}) {
    if (port == null) {
      this.baseUrl = "$protocol://$host";
    } else {
      this.baseUrl = "$protocol://$host:$port";
    }

    if (!this.baseUrl.endsWith("/")) {
      this.baseUrl += "/";
    }

    this.path = path;
    if (this.path.isNotEmpty && this.path != "/") {
      this.baseUrl = this.baseUrl + this.path;
    }
    this.httpClient.addCredentials(Uri.parse(this.baseUrl), "",
        HttpClientBasicCredentials(username, password));
  }

  /// get url from given [path]
  String getUrl(String path) {
    path = path.trim();

    if (path.startsWith('/')) {
      // Since the base url ends with "/" by default trim of one char at the
      // beginning of the path
      return this.baseUrl + path.substring(1, path.length);
    }

    // If the path does not start with "/" append it after the baseUrl
    return [this.baseUrl, path].join('');
  }

  /// change current dir to the given [path]
  void cd(String path) {
    path = path.trim();
    if (path.isEmpty) {
      return;
    }
    List tmp = path.split("/");
    tmp.removeWhere((value) => value == null || value == '');
    String strippedPath = tmp.join('/') + '/';
    if (strippedPath == '/') {
      this.cwd = strippedPath;
    } else if (path.startsWith("/")) {
      this.cwd = '/' + strippedPath;
    } else {
      this.cwd += strippedPath;
    }
  }

  /// send the request with given [method] and [path]
  ///
  Future<HttpClientResponse> _send(
      String method, String path, List<int> expectedCodes,
      {Uint8List data, Map headers}) async {
    return await retry(
        () => this
            .__send(method, path, expectedCodes, data: data, headers: headers),
        retryIf: (e) => e is WebDavException,
        maxAttempts: 5);
  }

  /// send the request with given [method] and [path]
  Future<HttpClientResponse> __send(
      String method, String path, List<int> expectedCodes,
      {Uint8List data, Map headers}) async {
    String url = this.getUrl(path);
    print("[webdav] http send with method:$method path:$path url:$url");

    HttpClientRequest request =
        await this.httpClient.openUrl(method, Uri.parse(url));
    request
      ..followRedirects = false
      ..persistentConnection = true;

    if (data != null) {
      request.add(data);
    }
    if (headers != null) {
      headers.forEach((k, v) => request.headers.add(k, v));
    }

    HttpClientResponse response = await request.close();
    if (!expectedCodes.contains(response.statusCode)) {
      print('$path ${response.statusCode}');
      throw WebDavException(
          "operation failed method:$method "
          "path:$path exceptionCodes:$expectedCodes "
          "statusCode:${response.statusCode}",
          response.statusCode);
    }
    return response;
  }

  /// make a dir with [path] under current dir
  Future<HttpClientResponse> mkdir(String path, [bool safe = true]) {
    List<int> expectedCodes = [201];
    if (safe) {
      expectedCodes.addAll([301, 405]);
    }
    return this._send('MKCOL', path, expectedCodes);
  }

  /// just like mkdir -p
  Future mkdirs(String path) async {
    path = path.trim();
    List<String> dirs = path.split("/");
    dirs.removeWhere((value) => value == null || value == '');
    if (dirs.isEmpty) {
      return;
    }
    if (path.startsWith("/")) {
      dirs[0] = '/' + dirs[0];
    }
    String oldCwd = this.cwd;
    try {
      for (String dir in dirs) {
        try {
          await this.mkdir(dir, true);
        } finally {
          this.cd(dir);
        }
      }
    } catch (e) {
    } finally {
      this.cd(oldCwd);
    }
  }

  /// remove dir with given [path]
  Future rmdir(String path, [bool safe = true]) async {
    path = path.trim();
    List<int> expectedCodes = [204];
    if (safe) {
      expectedCodes.addAll([204, 404]);
    }
    await this._send('DELETE', path, expectedCodes);
  }

  /// remove dir with given [path]
  Future delete(String path) async {
    await this._send('DELETE', path, [204]);
  }

  /// upload a new file with [localData] as content to [remotePath]
  Future _upload(Uint8List localData, String remotePath) async {
    return await this
        ._send('PUT', remotePath, [200, 201, 204], data: localData);
  }

  /// upload a new file with [localData] as content to [remotePath]
  Future upload(Uint8List data, String remotePath) async {
    this._upload(data, remotePath);
  }

  /// upload local file [path] to [remotePath]
  Future uploadFile(String path, String remotePath) async {
    return this._upload(await File(path).readAsBytes(), remotePath);
  }

  /// download [remotePath] to local file [localFilePath]
  Future download(String remotePath, String localFilePath) async {
    print('[webdav] download from $remotePath to $localFilePath');
    HttpClientResponse response = await this._send('GET', remotePath, [200]);

    print('[webdav] download statuscode ${response.statusCode}--');
    await response.pipe(new File(localFilePath).openWrite());
  }

  /// download [remotePath] and store the response file contents to String
  Future<String> downloadToBinaryString(String remotePath) async {
    HttpClientResponse response = await this._send('GET', remotePath, [200]);
    return response.transform(utf8.decoder).join();
  }

  /// list the directories and files under given [remotePath]
  Future<List<FileInfo>> ls(String remotePath, {int depth = 1}) async {
    Map userHeader = {"Depth": depth};
    HttpClientResponse response = await this
        ._send('PROPFIND', remotePath, [207, 301], headers: userHeader);
    if (response.statusCode == 301) {
      return this.ls(response.headers.value('location'));
    }
    return treeFromWebDavXml(await response.transform(utf8.decoder).join());
  }
}

class FileInfo {
  String path;
  String size;
  String modificationTime;
  DateTime creationTime;
  String contentType;

  FileInfo(this.path, this.size, this.modificationTime, this.creationTime,
      this.contentType);

  // Returns the decoded name of the file / folder without the whole path
  String get name {
    if (this.isDirectory) {
      return Uri.decodeFull(
          this.path.substring(0, this.path.lastIndexOf("/")).split("/").last);
    }

    return Uri.decodeFull(this.path.split("/").last);
  }

  bool get isDirectory => this.path.endsWith("/");

  @override
  String toString() {
    return 'FileInfo{name: $name, isDirectory: $isDirectory ,path: $path, size: $size, modificationTime: $modificationTime, creationTime: $creationTime, contentType: $contentType}';
  }
}

/// get filed [name] from the property node
String prop(dynamic prop, String name, [String defaultVal]) {
  if (prop is Map) {
    final val = prop['D:' + name];
    if (val == null) {
      return defaultVal;
    }
    return val;
  }
  return defaultVal;
}

List<FileInfo> treeFromWebDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  var tree = <FileInfo>[];

  // parse the xml using the xml.parse method

  var xmlDocument = xml.XmlDocument.parse(xmlStr);

  // Iterate over the response to find all folders / files and parse the information
  findAllElementsFromDocument(xmlDocument, "response").forEach((response) {
    var davItemName = findElementsFromElement(response, "href").single.text;
    findElementsFromElement(
            findElementsFromElement(response, "propstat").first, "prop")
        .forEach((element) {
      final contentLengthElements =
          findElementsFromElement(element, "getcontentlength");
      final contentLength = contentLengthElements.isNotEmpty
          ? contentLengthElements.single.text
          : "";

      final lastModifiedElements =
          findElementsFromElement(element, "getlastmodified");
      final lastModified = lastModifiedElements.isNotEmpty
          ? lastModifiedElements.single.text
          : "";

      final creationTimeElements =
          findElementsFromElement(element, "creationdate");
      final creationTime = creationTimeElements.isNotEmpty
          ? creationTimeElements.single.text
          : DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

      // Add the just found file to the tree
      tree.add(new FileInfo(davItemName, contentLength, lastModified,
          DateTime.parse(creationTime), ""));
    });
  });

  // Return the tree
  return tree;
}

List<xml.XmlElement> findAllElementsFromDocument(
        xml.XmlDocument document, String tag) =>
    (document.findAllElements("d:$tag").toList()
      ..addAll(document.findAllElements("D:$tag")));

List<xml.XmlElement> findElementsFromElement(
        xml.XmlElement element, String tag) =>
    (element.findElements("d:$tag").toList()
      ..addAll(element.findElements("D:$tag")));
