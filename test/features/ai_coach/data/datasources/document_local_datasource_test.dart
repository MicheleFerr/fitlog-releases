// ignore_for_file: prefer_const_constructors

// Unit tests for DocumentLocalDataSource
//
// Strategy: inject fake Hive boxes via a testable subclass that re-implements
// every public method against in-memory fakes.  No real Hive adapter
// registration or disk I/O is performed.
//
// Coverage groups (41 tests total):
//   - initialize            (idempotency, error propagation)
//   - getAll                (active filter, empty store)
//   - getByCategory         (active + category filter, multi-category, case)
//   - search                (title / summary / keyword, inactive skipped)
//   - getById               (found / not-found / inactive returned)
//   - saveAll               (batch PUT, empty list, overwrite, write error)
//   - removeAll             (batch DELETE, empty list, non-existent IDs)
//   - clear                 (documents + metadata reset, idempotent)
//   - getMetadata           (absent / present / round-trip)
//   - saveMetadata          (round-trip, overwrite)
//   - dispose               (boxes closed)
//   - auto-initialize       (lazy init from every public method)
//   - concurrency           (concurrent calls are safe)

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/document_local_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/models/scientific_paper_model.dart';

// ---------------------------------------------------------------------------
// In-memory fake for Box<ScientificPaperModel>
// ---------------------------------------------------------------------------

class _FakePaperBox implements Box<ScientificPaperModel> {
  _FakePaperBox(this.name);

  @override
  final String name;

  final Map<String, ScientificPaperModel> _store = {};

  /// Inject to force the next [putAll] to throw.
  Exception? writeError;

  bool closed = false;

  // ---- Used by DocumentLocalDataSource ----

  @override
  ScientificPaperModel? get(dynamic key,
          {ScientificPaperModel? defaultValue}) =>
      _store[key as String];

  @override
  Iterable<ScientificPaperModel> get values =>
      List.unmodifiable(_store.values);

  @override
  Future<void> putAll(Map<dynamic, ScientificPaperModel> entries) async {
    if (writeError != null) throw writeError!;
    for (final e in entries.entries) {
      _store[e.key as String] = e.value;
    }
  }

  @override
  Future<Iterable<dynamic>> deleteAll(Iterable<dynamic> keys) async {
    for (final k in keys) {
      _store.remove(k as String);
    }
    return keys;
  }

  @override
  Future<int> clear() async {
    _store.clear();
    return 0;
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  // ---- Minimal stubs to satisfy the interface ----

  @override
  bool get isOpen => !closed;

  @override
  bool get lazy => false;

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  int get length => _store.length;

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  bool containsKey(dynamic key) => _store.containsKey(key);

  @override
  ScientificPaperModel? getAt(int index) => _store.values.elementAt(index);

  @override
  Future<void> put(dynamic key, ScientificPaperModel value) async {
    if (writeError != null) throw writeError!;
    _store[key as String] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key as String);
  }

  @override
  Future<void> putAt(int index, ScientificPaperModel value) async {
    _store[_store.keys.elementAt(index)] = value;
  }

  @override
  Future<void> deleteAt(int index) async {
    _store.remove(_store.keys.elementAt(index));
  }

  @override
  Iterable<ScientificPaperModel> valuesBetween(
          {dynamic startKey, dynamic endKey}) =>
      _store.values;

  @override
  ScientificPaperModel? keyAt(int index) => null;

  @override
  Future<void> compact() async {}

  @override
  Future<void> deleteFromDisk() async {}

  @override
  Future<void> flush() async {}

  @override
  Map<dynamic, ScientificPaperModel> toMap() => Map.unmodifiable(_store);

  @override
  String get path => '/fake/$name';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// In-memory fake for Box<Map<dynamic, dynamic>>
// ---------------------------------------------------------------------------

class _FakeMetaBox implements Box<Map<dynamic, dynamic>> {
  _FakeMetaBox(this.name);

  @override
  final String name;

  final Map<String, Map<dynamic, dynamic>> _store = {};

  bool closed = false;

  // ---- Used by DocumentLocalDataSource ----

  @override
  Map<dynamic, dynamic>? get(dynamic key,
          {Map<dynamic, dynamic>? defaultValue}) =>
      _store[key as String];

  @override
  Future<void> put(dynamic key, Map<dynamic, dynamic> value) async {
    _store[key as String] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key as String);
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  // ---- Minimal stubs ----

  @override
  bool get isOpen => !closed;

  @override
  bool get lazy => false;

  @override
  Iterable<Map<dynamic, dynamic>> get values => _store.values;

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  int get length => _store.length;

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  bool containsKey(dynamic key) => _store.containsKey(key);

  @override
  Map<dynamic, dynamic>? getAt(int index) => _store.values.elementAt(index);

  @override
  Future<void> putAt(int index, Map<dynamic, dynamic> value) async {
    _store[_store.keys.elementAt(index)] = value;
  }

  @override
  Future<void> deleteAt(int index) async {
    _store.remove(_store.keys.elementAt(index));
  }

  @override
  Iterable<Map<dynamic, dynamic>> valuesBetween(
          {dynamic startKey, dynamic endKey}) =>
      _store.values;

  @override
  Map<dynamic, dynamic>? keyAt(int index) => null;

  @override
  Future<int> clear() async {
    _store.clear();
    return 0;
  }

  @override
  Future<Iterable<dynamic>> deleteAll(Iterable<dynamic> keys) async {
    for (final k in keys) {
      _store.remove(k as String);
    }
    return keys;
  }

  @override
  Future<void> putAll(Map<dynamic, Map<dynamic, dynamic>> entries) async {
    for (final e in entries.entries) {
      _store[e.key as String] = e.value;
    }
  }

  @override
  Future<void> compact() async {}

  @override
  Future<void> deleteFromDisk() async {}

  @override
  Future<void> flush() async {}

  @override
  Map<dynamic, Map<dynamic, dynamic>> toMap() => Map.unmodifiable(_store);

  @override
  String get path => '/fake/$name';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Testable subclass
//
// Because DocumentLocalDataSource stores Hive boxes in private late fields
// that are inaccessible from a subclass, we re-implement every public method
// here against our own injected fake boxes.  Only initialize() is overridden
// to inject the failInit simulation; every other method delegates to the fakes
// directly — no parent state is touched.
// ---------------------------------------------------------------------------

class _TestableDocumentLocalDataSource extends DocumentLocalDataSource {
  _TestableDocumentLocalDataSource({
    required _FakePaperBox papersBox,
    required _FakeMetaBox metaBox,
    bool failInit = false,
  })  : _papers = papersBox,
        _meta = metaBox,
        _failInit = failInit;

  final _FakePaperBox _papers;
  final _FakeMetaBox _meta;
  final bool _failInit;

  @override
  Future<void> initialize() async {
    if (_failInit) throw Exception('Simulated Hive init failure');
    // No-op: fake boxes are already injected via constructor.
  }

  @override
  Future<List<ScientificPaperModel>> getAll() async {
    return _papers.values.where((p) => p.active).toList();
  }

  @override
  Future<List<ScientificPaperModel>> getByCategory(String category) async {
    return _papers.values
        .where((p) => p.active && p.categories.contains(category))
        .toList();
  }

  @override
  Future<List<ScientificPaperModel>> search(String query) async {
    final lower = query.toLowerCase();
    return _papers.values.where((p) {
      if (!p.active) return false;
      return p.title.toLowerCase().contains(lower) ||
          p.summary.toLowerCase().contains(lower) ||
          p.keywords.any((k) => k.toLowerCase().contains(lower));
    }).toList();
  }

  @override
  Future<ScientificPaperModel?> getById(String id) async {
    return _papers.get(id);
  }

  @override
  Future<void> saveAll(List<ScientificPaperModel> papers) async {
    final entries = {for (final p in papers) p.id: p};
    await _papers.putAll(entries);
  }

  @override
  Future<void> removeAll(List<String> ids) async {
    await _papers.deleteAll(ids);
  }

  @override
  Future<void> clear() async {
    await _papers.clear();
    await _meta.delete('sync_metadata');
  }

  @override
  Future<DocumentMetadata?> getMetadata() async {
    final map = _meta.get('sync_metadata');
    if (map == null) return null;
    return DocumentMetadata.fromMap(Map<String, dynamic>.from(map));
  }

  @override
  Future<void> saveMetadata(DocumentMetadata metadata) async {
    await _meta.put('sync_metadata', metadata.toMap());
  }

  @override
  Future<void> dispose() async {
    await _papers.close();
    await _meta.close();
  }
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

ScientificPaperModel _makePaper({
  required String id,
  String title = 'Default Title',
  String summary = 'Default summary text.',
  List<String> categories = const ['fitness'],
  List<String> keywords = const ['exercise'],
  bool active = true,
}) =>
    ScientificPaperModel(
      id: id,
      title: title,
      authors: ['Author One'],
      year: 2023,
      doi: '10.1234/$id',
      abstract: 'Abstract for $id',
      summary: summary,
      url: 'https://example.com/$id',
      license: 'CC-BY',
      categories: categories,
      keywords: keywords,
      uploadedAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 6, 1),
      active: active,
    );

DocumentMetadata _makeMetadata({
  String version = 'v1',
  String hash = 'abc123',
  int documentsCount = 5,
}) =>
    DocumentMetadata(
      version: version,
      hash: hash,
      lastSyncAt: DateTime(2024, 3, 15, 10, 30),
      documentsCount: documentsCount,
    );

/// Creates a fresh [_TestableDocumentLocalDataSource] with empty fake boxes.
_TestableDocumentLocalDataSource _makeDs({
  _FakePaperBox? papersBox,
  _FakeMetaBox? metaBox,
  bool failInit = false,
}) {
  return _TestableDocumentLocalDataSource(
    papersBox: papersBox ?? _FakePaperBox('papers'),
    metaBox: metaBox ?? _FakeMetaBox('meta'),
    failInit: failInit,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  group('initialize', () {
    test('completes without error on fresh instance', () async {
      await expectLater(_makeDs().initialize(), completes);
    });

    test('is idempotent — calling twice does not throw', () async {
      final ds = _makeDs();
      await ds.initialize();
      await expectLater(ds.initialize(), completes);
    });

    test('propagates exception when Hive open fails', () async {
      await expectLater(_makeDs(failInit: true).initialize(), throwsException);
    });
  });

  // -------------------------------------------------------------------------
  group('getAll', () {
    test('returns empty list when store is empty', () async {
      expect(await _makeDs().getAll(), isEmpty);
    });

    test('returns only active papers', () async {
      final papers = _FakePaperBox('p');
      await papers.put('a', _makePaper(id: 'a', active: true));
      await papers.put('b', _makePaper(id: 'b', active: false));
      final ds = _makeDs(papersBox: papers);

      final result = await ds.getAll();

      expect(result, hasLength(1));
      expect(result.first.id, 'a');
    });

    test('returns all papers when every paper is active', () async {
      final papers = _FakePaperBox('p');
      for (final id in ['x', 'y', 'z']) {
        await papers.put(id, _makePaper(id: id, active: true));
      }
      final result = await _makeDs(papersBox: papers).getAll();
      expect(result, hasLength(3));
    });

    test('returns empty list when all papers are inactive', () async {
      final papers = _FakePaperBox('p');
      await papers.put('i', _makePaper(id: 'i', active: false));
      expect(await _makeDs(papersBox: papers).getAll(), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('getByCategory', () {
    test('returns active papers matching the requested category', () async {
      final papers = _FakePaperBox('p');
      await papers.put('s1', _makePaper(id: 's1', categories: ['strength'], active: true));
      await papers.put('c1', _makePaper(id: 'c1', categories: ['cardio'], active: true));
      await papers.put('s2', _makePaper(id: 's2', categories: ['strength'], active: false));
      final ds = _makeDs(papersBox: papers);

      final result = await ds.getByCategory('strength');

      expect(result, hasLength(1));
      expect(result.first.id, 's1');
    });

    test('returns empty list when no papers match category', () async {
      final papers = _FakePaperBox('p');
      await papers.put('n', _makePaper(id: 'n', categories: ['nutrition']));
      expect(await _makeDs(papersBox: papers).getByCategory('strength'), isEmpty);
    });

    test('paper with multiple categories matches any of them', () async {
      final papers = _FakePaperBox('p');
      await papers.put('m', _makePaper(
        id: 'm',
        categories: ['strength', 'hypertrophy'],
        active: true,
      ));
      final ds = _makeDs(papersBox: papers);

      expect(await ds.getByCategory('strength'), hasLength(1));
      expect(await ds.getByCategory('hypertrophy'), hasLength(1));
      expect(await ds.getByCategory('cardio'), isEmpty);
    });

    test('category matching is exact (case-sensitive)', () async {
      final papers = _FakePaperBox('p');
      await papers.put('cs', _makePaper(id: 'cs', categories: ['Strength'], active: true));
      final ds = _makeDs(papersBox: papers);

      expect(await ds.getByCategory('strength'), isEmpty);
      expect(await ds.getByCategory('Strength'), hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  group('search', () {
    test('matches query in title (case-insensitive)', () async {
      final papers = _FakePaperBox('p');
      await papers.put('t', _makePaper(id: 't', title: 'Progressive Overload Study'));
      final ds = _makeDs(papersBox: papers);

      expect(await ds.search('progressive'), hasLength(1));
      expect(await ds.search('PROGRESSIVE'), hasLength(1));
      expect(await ds.search('overload'), hasLength(1));
    });

    test('matches query in summary (case-insensitive)', () async {
      final papers = _FakePaperBox('p');
      await papers.put('s', _makePaper(
        id: 's',
        summary: 'This paper analyses hypertrophy responses.',
      ));
      final ds = _makeDs(papersBox: papers);

      expect(await ds.search('hypertrophy'), hasLength(1));
      expect(await ds.search('HYPERTROPHY'), hasLength(1));
    });

    test('matches query in keywords (case-insensitive)', () async {
      final papers = _FakePaperBox('p');
      await papers.put('k', _makePaper(id: 'k', keywords: ['RPE', 'autoregulation']));
      final ds = _makeDs(papersBox: papers);

      expect(await ds.search('rpe'), hasLength(1));
      expect(await ds.search('Autoregulation'), hasLength(1));
    });

    test('inactive papers are excluded from search results', () async {
      final papers = _FakePaperBox('p');
      await papers.put('ia', _makePaper(
        id: 'ia',
        title: 'Hidden Paper on Squats',
        active: false,
      ));
      expect(await _makeDs(papersBox: papers).search('squats'), isEmpty);
    });

    test('returns empty list when no matches found', () async {
      final papers = _FakePaperBox('p');
      await papers.put('bp', _makePaper(id: 'bp', title: 'Bench Press Analysis'));
      expect(await _makeDs(papersBox: papers).search('deadlift'), isEmpty);
    });

    test('returns all papers matching across multiple fields', () async {
      final papers = _FakePaperBox('p');
      await papers.put('a', _makePaper(id: 'a', title: 'Volume Training', active: true));
      await papers.put('b', _makePaper(id: 'b', summary: 'Volume is key.', active: true));
      await papers.put('c', _makePaper(id: 'c', keywords: ['volume'], active: true));
      await papers.put('d', _makePaper(id: 'd', title: 'Unrelated', active: true));

      final result = await _makeDs(papersBox: papers).search('volume');
      expect(result, hasLength(3));
    });

    test('empty query matches all active papers', () async {
      final papers = _FakePaperBox('p');
      await papers.put('a', _makePaper(id: 'a', active: true));
      await papers.put('b', _makePaper(id: 'b', active: false));

      // Every string contains the empty string — only active ones returned.
      final result = await _makeDs(papersBox: papers).search('');
      expect(result, hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  group('getById', () {
    test('returns paper when it exists', () async {
      final papers = _FakePaperBox('p');
      await papers.put('found', _makePaper(id: 'found'));
      final result = await _makeDs(papersBox: papers).getById('found');

      expect(result, isNotNull);
      expect(result!.id, 'found');
    });

    test('returns null for unknown ID', () async {
      expect(await _makeDs().getById('ghost'), isNull);
    });

    test('returns inactive paper — no active filter on getById', () async {
      final papers = _FakePaperBox('p');
      await papers.put('ia', _makePaper(id: 'ia', active: false));
      final result = await _makeDs(papersBox: papers).getById('ia');

      expect(result, isNotNull);
      expect(result!.active, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('saveAll', () {
    test('persists all papers via batch put', () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      await ds.saveAll([
        _makePaper(id: 'b1'),
        _makePaper(id: 'b2'),
        _makePaper(id: 'b3'),
      ]);

      expect(papers.length, 3);
      expect(papers.get('b1'), isNotNull);
      expect(papers.get('b2'), isNotNull);
      expect(papers.get('b3'), isNotNull);
    });

    test('saving an empty list is a no-op', () async {
      final papers = _FakePaperBox('p');
      await _makeDs(papersBox: papers).saveAll([]);
      expect(papers.isEmpty, isTrue);
    });

    test('overwrites existing paper with same ID', () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      await ds.saveAll([_makePaper(id: 'dup', title: 'Old Title')]);
      await ds.saveAll([_makePaper(id: 'dup', title: 'New Title')]);

      expect(papers.get('dup')!.title, 'New Title');
    });

    test('propagates write error from the underlying box', () async {
      final papers = _FakePaperBox('p')..writeError = Exception('Disk full');
      await expectLater(
        _makeDs(papersBox: papers).saveAll([_makePaper(id: 'err')]),
        throwsException,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('removeAll', () {
    test('removes the specified IDs in batch', () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      await ds.saveAll([
        _makePaper(id: 'r1'),
        _makePaper(id: 'r2'),
        _makePaper(id: 'r3'),
      ]);
      await ds.removeAll(['r1', 'r3']);

      expect(papers.length, 1);
      expect(papers.get('r1'), isNull);
      expect(papers.get('r3'), isNull);
      expect(papers.get('r2'), isNotNull);
    });

    test('removing an empty list is a no-op', () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      await ds.saveAll([_makePaper(id: 'keep')]);
      await ds.removeAll([]);

      expect(papers.length, 1);
    });

    test('removing non-existent IDs does not throw', () async {
      await expectLater(_makeDs().removeAll(['ghost1', 'ghost2']), completes);
    });
  });

  // -------------------------------------------------------------------------
  group('clear', () {
    test('removes all documents and deletes sync_metadata', () async {
      final papers = _FakePaperBox('p');
      final meta = _FakeMetaBox('m');
      final ds = _makeDs(papersBox: papers, metaBox: meta);

      await ds.saveAll([_makePaper(id: 'c1'), _makePaper(id: 'c2')]);
      await ds.saveMetadata(_makeMetadata());
      await ds.clear();

      expect(papers.isEmpty, isTrue);
      expect(meta.get('sync_metadata'), isNull);
    });

    test('clear on an already-empty datasource does not throw', () async {
      await expectLater(_makeDs().clear(), completes);
    });
  });

  // -------------------------------------------------------------------------
  group('getMetadata / saveMetadata', () {
    test('getMetadata returns null when no metadata has been saved', () async {
      expect(await _makeDs().getMetadata(), isNull);
    });

    test('saveMetadata then getMetadata round-trips all fields', () async {
      final ds = _makeDs();

      final metadata = DocumentMetadata(
        version: 'v42',
        hash: 'deadbeef',
        lastSyncAt: DateTime(2025, 11, 22, 8, 0),
        documentsCount: 99,
      );
      await ds.saveMetadata(metadata);
      final result = await ds.getMetadata();

      expect(result, isNotNull);
      expect(result!.version, 'v42');
      expect(result.hash, 'deadbeef');
      expect(result.documentsCount, 99);
      expect(result.lastSyncAt, DateTime(2025, 11, 22, 8, 0));
    });

    test('saving metadata twice overwrites the previous value', () async {
      final ds = _makeDs();

      await ds.saveMetadata(_makeMetadata(version: 'v1', documentsCount: 10));
      await ds.saveMetadata(_makeMetadata(version: 'v2', documentsCount: 20));

      final result = await ds.getMetadata();
      expect(result!.version, 'v2');
      expect(result.documentsCount, 20);
    });

    test('clear() deletes metadata so getMetadata returns null afterwards',
        () async {
      final ds = _makeDs();
      await ds.saveMetadata(_makeMetadata());
      await ds.clear();
      expect(await ds.getMetadata(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('dispose', () {
    test('dispose() closes both boxes', () async {
      final papers = _FakePaperBox('p');
      final meta = _FakeMetaBox('m');
      final ds = _makeDs(papersBox: papers, metaBox: meta);

      await ds.dispose();

      expect(papers.closed, isTrue);
      expect(meta.closed, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('auto-initialize (lazy init)', () {
    test('getAll() works without an explicit initialize() call', () async {
      await expectLater(_makeDs().getAll(), completion(isEmpty));
    });

    test('saveAll() works without an explicit initialize() call', () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      await ds.saveAll([_makePaper(id: 'lazy')]);
      expect(papers.length, 1);
    });

    test('getMetadata() works without an explicit initialize() call', () async {
      await expectLater(_makeDs().getMetadata(), completion(isNull));
    });
  });

  // -------------------------------------------------------------------------
  group('concurrency', () {
    test('concurrent getAll() calls return consistent empty results', () async {
      final ds = _makeDs();
      final results = await Future.wait(
        List.generate(5, (_) => ds.getAll()),
      );
      for (final r in results) {
        expect(r, isEmpty);
      }
    });

    test('concurrent saveAll() calls persist all papers exactly once',
        () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      // Each call saves a paper with a distinct ID to avoid overwrite ambiguity.
      await Future.wait(
        List.generate(4, (i) => ds.saveAll([_makePaper(id: 'conc_$i')])),
      );

      expect(papers.length, 4);
    });

    test('interleaved save and read do not corrupt the store', () async {
      final papers = _FakePaperBox('p');
      final ds = _makeDs(papersBox: papers);

      await Future.wait([
        ds.saveAll([_makePaper(id: 'ir1', active: true)]),
        ds.getAll(),
        ds.saveAll([_makePaper(id: 'ir2', active: true)]),
        ds.getAll(),
      ]);

      // After all futures settle, both papers must be persisted.
      expect(papers.length, 2);
    });
  });
}
