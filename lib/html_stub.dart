library html_stub;

class StorageEvent {
  final String? key;
  final String? newValue;
  StorageEvent({this.key, this.newValue});
}

class _DummyStorage {
  final Map<String, String> _map = {};
  String? operator [](String key) => _map[key];
  void operator []=(String key, String value) => _map[key] = value;
  void remove(String key) => _map.remove(key);
}

class _DummyHistory {
  void replaceState(Object? data, String title, String url) {}
}

class _DummyLocation {
  void assign(String url) {}
}

class _DummyWindow {
  final _DummyStorage localStorage = _DummyStorage();
  final _DummyHistory history = _DummyHistory();
  final _DummyLocation location = _DummyLocation();
  Stream<StorageEvent> get onStorage => const Stream.empty();
}

final _DummyWindow window = _DummyWindow();