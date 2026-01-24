/// Script per verificare le collection exercises su Firebase
///
/// Esegui con:
/// ```bash
/// flutter run -t scripts/verify_firebase_collections.dart -d macos
/// ```
library;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  runApp(const VerifyApp());
}

class VerifyApp extends StatelessWidget {
  const VerifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verify Firebase Collections',
      theme: ThemeData.dark(),
      home: const VerifyScreen(),
    );
  }
}

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<String> _logs = [];
  bool _isChecking = false;

  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
    // ignore: avoid_print
    print(message);
  }

  Future<void> _verifyCollections() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
      _logs.clear();
    });

    final firestore = FirebaseFirestore.instance;

    try {
      _log('🔍 Checking Firebase collections...');
      _log('');

      // Check exercises_it
      _log('📦 Collection: exercises_it');
      final itSnapshot = await firestore.collection('exercises_it').limit(5).get();
      _log('   Documents: ${itSnapshot.docs.length} (showing max 5)');
      if (itSnapshot.docs.isNotEmpty) {
        _log('   First doc ID: ${itSnapshot.docs.first.id}');
        final data = itSnapshot.docs.first.data();
        _log('   Fields: ${data.keys.join(', ')}');
      }

      // Count total
      final itCountSnapshot = await firestore.collection('exercises_it').count().get();
      _log('   TOTAL COUNT: ${itCountSnapshot.count}');
      _log('');

      // Check exercises_en
      _log('📦 Collection: exercises_en');
      final enSnapshot = await firestore.collection('exercises_en').limit(5).get();
      _log('   Documents: ${enSnapshot.docs.length} (showing max 5)');
      if (enSnapshot.docs.isNotEmpty) {
        _log('   First doc ID: ${enSnapshot.docs.first.id}');
        final data = enSnapshot.docs.first.data();
        _log('   Fields: ${data.keys.join(', ')}');
      }

      // Count total
      final enCountSnapshot = await firestore.collection('exercises_en').count().get();
      _log('   TOTAL COUNT: ${enCountSnapshot.count}');
      _log('');

      // Check metadata
      _log('📦 Collection: exercises_metadata');
      final metaDoc = await firestore.collection('exercises_metadata').doc('version_info').get();
      if (metaDoc.exists) {
        final data = metaDoc.data()!;
        _log('   current_version: ${data['current_version']}');
        _log('   total_exercises_it: ${data['total_exercises_it']}');
        _log('   total_exercises_en: ${data['total_exercises_en']}');
        _log('   status: ${data['status']}');
      } else {
        _log('   ❌ version_info document not found!');
      }

      _log('');
      _log('✅ Verification complete');

    } catch (e) {
      _log('');
      _log('❌ ERROR: $e');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Firebase Collections'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _verifyCollections,
              icon: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isChecking ? 'Checking...' : 'Verify Collections'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
