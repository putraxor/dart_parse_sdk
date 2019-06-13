part of flutter_parse_sdk;

Future<Directory> getTemporaryDirectory() async {
  return Directory.systemTemp;
  // Directory path = Directory('${Directory.current.path}/tmp');
  // if (!path.existsSync()) {
  //   path.createSync(recursive: true);
  // }
  // return path;
}

Future<Directory> getApplicationDocumentsDirectory() async {
  return Directory.systemTemp;
}
