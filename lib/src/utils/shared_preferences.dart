part of flutter_parse_sdk;

/// Data is persisted to disk asynchronously.
class SharedPreferences {
  SharedPreferences._(this._preferenceCache);

  static const String _prefix = 'flutter.';

  static SharedPreferences _instance;
  static Future<SharedPreferences> getInstance() async {
    if (_instance == null) {
      Map<Object, Object> fromSystem = <String, Object>{};

      final temp = (await getTemporaryDirectory());
      File _preferencesFile = File('${temp.path}/${_prefix}pref');
      if (_preferencesFile.existsSync()) {
        String content = _preferencesFile.readAsStringSync();
        if (content.isNotEmpty) {
          fromSystem = json.decode(content);
        }
      } else {
        _preferencesFile.createSync(recursive: true);
      }
      assert(fromSystem != null);
      // Strip the flutter. prefix from the returned preferences.
      final Map<String, Object> preferencesMap = <String, Object>{};
      for (String key in fromSystem.keys) {
        assert(key.startsWith(_prefix));
        preferencesMap[key.substring(_prefix.length)] = fromSystem[key];
      }
      _instance = SharedPreferences._(preferencesMap);
    }
    return _instance;
  }

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  final Map<String, Object> _preferenceCache;

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  dynamic get(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double getDouble(String key) => _preferenceCache[key];

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key) => _preferenceCache[key];

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String> getStringList(String key) {
    List<Object> list = _preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      _preferenceCache[key] = list;
    }
    return list;
  }

  ///Get file preference location
  File _preferenceFile;
  Future<File> _getPreferencePath() async {
    if (_preferenceFile == null) {
      final temp = (await getTemporaryDirectory());
      _preferenceFile = File('${temp.path}/${_prefix}pref');
    }
    return _preferenceFile;
  }

  ///Commit file preference to local temp directory
  Future<bool> _commitPreference() async {
    File file = await _getPreferencePath();
    file.writeAsStringSync(json.encode(_preferenceCache));
    return true;
  }

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) => _setValue('Bool', key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => _setValue('Int', key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) =>
      _setValue('Double', key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) =>
      _setValue('String', key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) =>
      _setValue('StringList', key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(null, key, null);

  Future<bool> _setValue(String valueType, String key, Object value) {
    final Map<String, dynamic> params = <String, dynamic>{
      'key': '$_prefix$key',
    };
    if (value == null) {
      _preferenceCache.remove(key);
      return _commitPreference();
    } else {
      _preferenceCache[key] = value;
      params['value'] = value;
      return _commitPreference();
    }
  }

  Future<bool> clear() async {
    _preferenceCache.clear();
    return _commitPreference();
  }
}
