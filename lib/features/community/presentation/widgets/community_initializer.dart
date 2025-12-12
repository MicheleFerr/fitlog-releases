import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget per inizializzare le collezioni Firestore se non esistono
class CommunityInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Inizializza le collezioni community se non esistono
  static Future<void> initializeCollections() async {
    try {
      // Verifica se la collezione community_contributions esiste
      final contributionsSnapshot = await _firestore
          .collection('community_contributions')
          .limit(1)
          .get();
      
      // Se non ci sono documenti, crea un documento di placeholder
      if (contributionsSnapshot.docs.isEmpty) {
        
        // Crea un documento di esempio/placeholder
        await _firestore.collection('community_contributions').doc('placeholder').set({
          'id': 'placeholder',
          'exerciseId': 'placeholder',
          'exerciseName': 'Placeholder Exercise',
          'userId': 'system',
          'userName': 'System',
          'type': 'tip',
          'status': 'approved',
          'title': 'Benvenuto nella Community',
          'description': 'Questo è un placeholder per inizializzare la collezione.',
          'upvotes': 0,
          'downvotes': 0,
          'upvotedBy': [],
          'downvotedBy': [],
          'comments': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
      }
      
      // Verifica se la collezione user_contribution_stats esiste
      final statsSnapshot = await _firestore
          .collection('user_contribution_stats')
          .limit(1)
          .get();
      
      if (statsSnapshot.docs.isEmpty) {
        
        // Crea un documento di esempio
        await _firestore.collection('user_contribution_stats').doc('placeholder').set({
          'userId': 'placeholder',
          'totalContributions': 0,
          'approvedContributions': 0,
          'rejectedContributions': 0,
          'totalUpvotes': 0,
          'totalDownvotes': 0,
          'badges': [],
          'level': 1,
          'xp': 0,
          'trustScore': 0.0,
          'lastActivity': FieldValue.serverTimestamp(),
        });
        
      }
      
    } catch (e) {
      // Non bloccare l'app se l'inizializzazione fallisce
    }
  }
  
  /// Widget wrapper che inizializza le collezioni al mount
  static Widget withInitialization({required Widget child}) {
    return _CommunityInitializerWidget(child: child);
  }
}

class _CommunityInitializerWidget extends StatefulWidget {
  
  const _CommunityInitializerWidget({
    required this.child,
  });
  final Widget child;
  
  @override
  State<_CommunityInitializerWidget> createState() => _CommunityInitializerWidgetState();
}

class _CommunityInitializerWidgetState extends State<_CommunityInitializerWidget> {
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    if (!_initialized) {
      await CommunityInitializer.initializeCollections();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}