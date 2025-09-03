import 'package:flutter_test/flutter_test.dart';

// Mock Database Service for testing
class DatabaseService {
  final Map<String, Map<String, dynamic>> _collections = {};
  final Map<String, List<DatabaseListener>> _listeners = {};
  final List<DatabaseOperation> _operationLog = [];
  bool _isConnected = true;
  
  // Connection management
  bool get isConnected => _isConnected;
  
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _isConnected = true;
    _logOperation(DatabaseOperation(
      type: OperationType.connect,
      timestamp: DateTime.now(),
    ));
  }
  
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _isConnected = false;
    _notifyListeners('connection', {'connected': false});
    _logOperation(DatabaseOperation(
      type: OperationType.disconnect,
      timestamp: DateTime.now(),
    ));
  }
  
  // CRUD Operations
  Future<String> create(String collection, Map<String, dynamic> data) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 20));
    
    final id = 'doc-${DateTime.now().millisecondsSinceEpoch}';
    final docData = {...data, 'id': id, 'createdAt': DateTime.now().toIso8601String()};
    
    _collections.putIfAbsent(collection, () => {});
    _collections[collection]![id] = docData;
    
    _notifyListeners(collection, {'type': 'created', 'id': id, 'data': docData});
    _logOperation(DatabaseOperation(
      type: OperationType.create,
      collection: collection,
      documentId: id,
      data: docData,
      timestamp: DateTime.now(),
    ));
    
    return id;
  }
  
  Future<Map<String, dynamic>?> read(String collection, String id) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 10));
    
    final doc = _collections[collection]?[id];
    
    _logOperation(DatabaseOperation(
      type: OperationType.read,
      collection: collection,
      documentId: id,
      data: doc,
      timestamp: DateTime.now(),
    ));
    
    return doc;
  }
  
  Future<List<Map<String, dynamic>>> readAll(String collection) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 20));
    
    final docs = _collections[collection]?.values.toList() ?? [];
    
    _logOperation(DatabaseOperation(
      type: OperationType.readAll,
      collection: collection,
      timestamp: DateTime.now(),
    ));
    
    return docs.cast<Map<String, dynamic>>();
  }
  
  Future<void> update(String collection, String id, Map<String, dynamic> data) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 20));
    
    final existing = _collections[collection]?[id];
    if (existing == null) throw Exception('Document not found');
    
    final updated = <String, dynamic>{
      ...existing,
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    _collections[collection]![id] = updated;
    
    _notifyListeners(collection, {'type': 'updated', 'id': id, 'data': updated});
    _logOperation(DatabaseOperation(
      type: OperationType.update,
      collection: collection,
      documentId: id,
      data: updated,
      timestamp: DateTime.now(),
    ));
  }
  
  Future<bool> delete(String collection, String id) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 20));
    
    final removed = _collections[collection]?.remove(id);
    
    if (removed != null) {
      _notifyListeners(collection, {'type': 'deleted', 'id': id});
      _logOperation(DatabaseOperation(
        type: OperationType.delete,
        collection: collection,
        documentId: id,
        timestamp: DateTime.now(),
      ));
      return true;
    }
    
    return false;
  }
  
  // Query operations
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 30));
    
    var results = (_collections[collection]?.values.toList() ?? []).cast<Map<String, dynamic>>();
    
    // Apply where clause
    if (where != null) {
      results = results.where((doc) {
        for (final entry in where.entries) {
          if (doc[entry.key] != entry.value) return false;
        }
        return true;
      }).toList();
    }
    
    // Apply ordering
    if (orderBy != null) {
      results.sort((a, b) {
        final aVal = a[orderBy];
        final bVal = b[orderBy];
        
        if (aVal == null) return descending ? -1 : 1;
        if (bVal == null) return descending ? 1 : -1;
        
        final comparison = aVal.compareTo(bVal);
        return descending ? -comparison : comparison;
      });
    }
    
    // Apply limit
    if (limit != null && results.length > limit) {
      results = results.take(limit).toList();
    }
    
    _logOperation(DatabaseOperation(
      type: OperationType.query,
      collection: collection,
      timestamp: DateTime.now(),
    ));
    
    return results;
  }
  
  // Batch operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    for (final op in operations) {
      switch (op.type) {
        case BatchOperationType.create:
          await create(op.collection, op.data!);
          break;
        case BatchOperationType.update:
          await update(op.collection, op.documentId!, op.data!);
          break;
        case BatchOperationType.delete:
          await delete(op.collection, op.documentId!);
          break;
      }
    }
    
    _logOperation(DatabaseOperation(
      type: OperationType.batch,
      timestamp: DateTime.now(),
    ));
  }
  
  // Transaction support
  Future<T> runTransaction<T>(Future<T> Function(Transaction) action) async {
    if (!_isConnected) throw Exception('Database not connected');
    
    final transaction = Transaction(this);
    
    try {
      final result = await action(transaction);
      await transaction.commit();
      
      _logOperation(DatabaseOperation(
        type: OperationType.transaction,
        timestamp: DateTime.now(),
      ));
      
      return result;
    } catch (e) {
      await transaction.rollback();
      rethrow;
    }
  }
  
  // Listener management
  void addListener(String collection, DatabaseListener listener) {
    _listeners.putIfAbsent(collection, () => []);
    _listeners[collection]!.add(listener);
  }
  
  void removeListener(String collection, DatabaseListener listener) {
    _listeners[collection]?.remove(listener);
  }
  
  void _notifyListeners(String collection, Map<String, dynamic> event) {
    final listeners = _listeners[collection] ?? [];
    for (final listener in listeners) {
      listener(event);
    }
  }
  
  // Statistics
  DatabaseStats getStats() {
    int totalDocuments = 0;
    int totalCollections = _collections.length;
    
    for (final collection in _collections.values) {
      totalDocuments += collection.length;
    }
    
    return DatabaseStats(
      totalCollections: totalCollections,
      totalDocuments: totalDocuments,
      totalOperations: _operationLog.length,
      isConnected: _isConnected,
    );
  }
  
  // Clear all data
  void clearAll() {
    _collections.clear();
    _listeners.clear();
    _operationLog.clear();
  }
  
  void _logOperation(DatabaseOperation operation) {
    _operationLog.add(operation);
  }
  
  List<DatabaseOperation> get operationLog => List.unmodifiable(_operationLog);
}

// Supporting classes
typedef DatabaseListener = void Function(Map<String, dynamic> event);

class DatabaseOperation {
  final OperationType type;
  final String? collection;
  final String? documentId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  
  DatabaseOperation({
    required this.type,
    this.collection,
    this.documentId,
    this.data,
    required this.timestamp,
  });
}

enum OperationType {
  connect,
  disconnect,
  create,
  read,
  readAll,
  update,
  delete,
  query,
  batch,
  transaction,
}

class BatchOperation {
  final BatchOperationType type;
  final String collection;
  final String? documentId;
  final Map<String, dynamic>? data;
  
  BatchOperation({
    required this.type,
    required this.collection,
    this.documentId,
    this.data,
  });
}

enum BatchOperationType {
  create,
  update,
  delete,
}

class Transaction {
  final DatabaseService _db;
  final List<BatchOperation> _operations = [];
  
  Transaction(this._db);
  
  void create(String collection, Map<String, dynamic> data) {
    _operations.add(BatchOperation(
      type: BatchOperationType.create,
      collection: collection,
      data: data,
    ));
  }
  
  void update(String collection, String id, Map<String, dynamic> data) {
    _operations.add(BatchOperation(
      type: BatchOperationType.update,
      collection: collection,
      documentId: id,
      data: data,
    ));
  }
  
  void delete(String collection, String id) {
    _operations.add(BatchOperation(
      type: BatchOperationType.delete,
      collection: collection,
      documentId: id,
    ));
  }
  
  Future<void> commit() async {
    await _db.batchWrite(_operations);
  }
  
  Future<void> rollback() async {
    _operations.clear();
  }
}

class DatabaseStats {
  final int totalCollections;
  final int totalDocuments;
  final int totalOperations;
  final bool isConnected;
  
  DatabaseStats({
    required this.totalCollections,
    required this.totalDocuments,
    required this.totalOperations,
    required this.isConnected,
  });
}

void main() {
  group('💾 Database Service Tests', () {
    late DatabaseService db;
    
    setUp(() {
      db = DatabaseService();
    });
    
    tearDown(() {
      db.clearAll();
    });
    
    group('🔌 Connection Management', () {
      test('✅ Connect to database', () async {
        await db.connect();
        expect(db.isConnected, true);
      });
      
      test('✅ Disconnect from database', () async {
        await db.connect();
        await db.disconnect();
        expect(db.isConnected, false);
      });
      
      test('❌ Operations fail when disconnected', () async {
        await db.disconnect();
        
        expect(
          () async => await db.create('users', {'name': 'John'}),
          throwsException,
        );
      });
    });
    
    group('📝 CRUD Operations', () {
      setUp(() async {
        await db.connect();
      });
      
      test('✅ Create document', () async {
        final id = await db.create('users', {
          'name': 'John Doe',
          'email': 'john@example.com',
        });
        
        expect(id, startsWith('doc-'));
        
        final doc = await db.read('users', id);
        expect(doc, isNotNull);
        expect(doc!['name'], 'John Doe');
        expect(doc['email'], 'john@example.com');
        expect(doc['id'], id);
        expect(doc['createdAt'], isNotNull);
      });
      
      test('✅ Read document', () async {
        final id = await db.create('users', {'name': 'Jane'});
        
        final doc = await db.read('users', id);
        expect(doc, isNotNull);
        expect(doc!['name'], 'Jane');
      });
      
      test('✅ Read non-existent document', () async {
        final doc = await db.read('users', 'non-existent');
        expect(doc, isNull);
      });
      
      test('✅ Read all documents', () async {
        await db.create('users', {'name': 'User 1'});
        await db.create('users', {'name': 'User 2'});
        await db.create('users', {'name': 'User 3'});
        
        final docs = await db.readAll('users');
        expect(docs.length, 3);
      });
      
      test('✅ Update document', () async {
        final id = await db.create('users', {'name': 'Original'});
        
        await db.update('users', id, {'name': 'Updated'});
        
        final doc = await db.read('users', id);
        expect(doc!['name'], 'Updated');
        expect(doc['updatedAt'], isNotNull);
      });
      
      test('❌ Update non-existent document', () async {
        expect(
          () async => await db.update('users', 'non-existent', {'name': 'Test'}),
          throwsException,
        );
      });
      
      test('✅ Delete document', () async {
        final id = await db.create('users', {'name': 'To Delete'});
        
        final deleted = await db.delete('users', id);
        expect(deleted, true);
        
        final doc = await db.read('users', id);
        expect(doc, isNull);
      });
      
      test('✅ Delete non-existent document', () async {
        final deleted = await db.delete('users', 'non-existent');
        expect(deleted, false);
      });
    });
    
    group('🔍 Query Operations', () {
      setUp(() async {
        await db.connect();
        
        // Create test data
        await db.create('products', {'name': 'Apple', 'price': 1.5, 'category': 'fruit'});
        await db.create('products', {'name': 'Banana', 'price': 1.0, 'category': 'fruit'});
        await db.create('products', {'name': 'Carrot', 'price': 0.8, 'category': 'vegetable'});
        await db.create('products', {'name': 'Tomato', 'price': 1.2, 'category': 'vegetable'});
      });
      
      test('✅ Query with where clause', () async {
        final fruits = await db.query('products', where: {'category': 'fruit'});
        
        expect(fruits.length, 2);
        expect(fruits.every((p) => p['category'] == 'fruit'), true);
      });
      
      test('✅ Query with ordering', () async {
        final products = await db.query('products', orderBy: 'price');
        
        expect(products.first['name'], 'Carrot'); // Cheapest
        expect(products.last['name'], 'Apple'); // Most expensive
      });
      
      test('✅ Query with descending order', () async {
        final products = await db.query('products', orderBy: 'price', descending: true);
        
        expect(products.first['name'], 'Apple'); // Most expensive first
        expect(products.last['name'], 'Carrot'); // Cheapest last
      });
      
      test('✅ Query with limit', () async {
        final products = await db.query('products', limit: 2);
        
        expect(products.length, 2);
      });
      
      test('✅ Complex query', () async {
        final results = await db.query(
          'products',
          where: {'category': 'fruit'},
          orderBy: 'price',
          descending: true,
          limit: 1,
        );
        
        expect(results.length, 1);
        expect(results.first['name'], 'Apple'); // Most expensive fruit
      });
    });
    
    group('📦 Batch Operations', () {
      setUp(() async {
        await db.connect();
      });
      
      test('✅ Batch write multiple operations', () async {
        await db.batchWrite([
          BatchOperation(
            type: BatchOperationType.create,
            collection: 'users',
            data: {'name': 'User 1'},
          ),
          BatchOperation(
            type: BatchOperationType.create,
            collection: 'users',
            data: {'name': 'User 2'},
          ),
        ]);
        
        final users = await db.readAll('users');
        expect(users.length, 2);
      });
      
      test('✅ Mixed batch operations', () async {
        final id = await db.create('users', {'name': 'Original'});
        
        await db.batchWrite([
          BatchOperation(
            type: BatchOperationType.update,
            collection: 'users',
            documentId: id,
            data: {'name': 'Updated'},
          ),
          BatchOperation(
            type: BatchOperationType.create,
            collection: 'users',
            data: {'name': 'New User'},
          ),
        ]);
        
        final users = await db.readAll('users');
        expect(users.length, 2);
        expect(users.any((u) => u['name'] == 'Updated'), true);
        expect(users.any((u) => u['name'] == 'New User'), true);
      });
    });
    
    group('🔄 Transactions', () {
      setUp(() async {
        await db.connect();
      });
      
      test('✅ Successful transaction', () async {
        final result = await db.runTransaction<String>((tx) async {
          tx.create('users', {'name': 'Transaction User'});
          tx.create('logs', {'action': 'user_created'});
          return 'success';
        });
        
        expect(result, 'success');
        
        final users = await db.readAll('users');
        final logs = await db.readAll('logs');
        
        expect(users.length, 1);
        expect(logs.length, 1);
      });
      
      test('✅ Transaction rollback on error', () async {
        try {
          await db.runTransaction<void>((tx) async {
            tx.create('users', {'name': 'Should not exist'});
            throw Exception('Transaction error');
          });
        } catch (e) {
          // Expected error
        }
        
        final users = await db.readAll('users');
        expect(users, isEmpty);
      });
    });
    
    group('👂 Listeners', () {
      setUp(() async {
        await db.connect();
      });
      
      test('✅ Listen to collection changes', () async {
        final events = <Map<String, dynamic>>[];
        
        db.addListener('users', (event) {
          events.add(event);
        });
        
        await db.create('users', {'name': 'Test User'});
        
        expect(events.length, 1);
        expect(events.first['type'], 'created');
      });
      
      test('✅ Multiple listeners', () async {
        int listener1Count = 0;
        int listener2Count = 0;
        
        db.addListener('users', (_) => listener1Count++);
        db.addListener('users', (_) => listener2Count++);
        
        await db.create('users', {'name': 'Test'});
        
        expect(listener1Count, 1);
        expect(listener2Count, 1);
      });
      
      test('✅ Remove listener', () async {
        int callCount = 0;
        void listener(Map<String, dynamic> event) {
          callCount++;
        }
        
        db.addListener('users', listener);
        await db.create('users', {'name': 'Test 1'});
        
        db.removeListener('users', listener);
        await db.create('users', {'name': 'Test 2'});
        
        expect(callCount, 1); // Only called once
      });
    });
    
    group('📊 Statistics', () {
      test('✅ Get database statistics', () async {
        await db.connect();
        
        await db.create('users', {'name': 'User 1'});
        await db.create('users', {'name': 'User 2'});
        await db.create('products', {'name': 'Product 1'});
        
        final stats = db.getStats();
        
        expect(stats.totalCollections, 2);
        expect(stats.totalDocuments, 3);
        expect(stats.totalOperations, greaterThan(3));
        expect(stats.isConnected, true);
      });
    });
    
    group('📋 Operation Logging', () {
      test('✅ Log all operations', () async {
        await db.connect();
        await db.create('users', {'name': 'Test'});
        await db.readAll('users');
        await db.disconnect();
        
        final log = db.operationLog;
        
        expect(log.any((op) => op.type == OperationType.connect), true);
        expect(log.any((op) => op.type == OperationType.create), true);
        expect(log.any((op) => op.type == OperationType.readAll), true);
        expect(log.any((op) => op.type == OperationType.disconnect), true);
      });
    });
  });
}