/// Template Folders Provider
///
/// Manages template folder state for coach organization.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_folder.dart';
import 'package:uuid/uuid.dart';

/// Provider for template folders
final templateFoldersProvider =
    AsyncNotifierProvider<TemplateFoldersNotifier, List<TemplateFolder>>(
      TemplateFoldersNotifier.new,
    );

/// Notifier for managing template folders
class TemplateFoldersNotifier extends AsyncNotifier<List<TemplateFolder>> {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  final _uuid = const Uuid();

  @override
  Future<List<TemplateFolder>> build() async {
    if (_userId == null) return [];
    return _loadFolders();
  }

  /// Load folders from Firestore
  Future<List<TemplateFolder>> _loadFolders() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('template_folders')
          .orderBy('sortOrder')
          .get();

      return snapshot.docs.map((doc) {
        return TemplateFolder.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a new folder
  Future<void> createFolder({
    required String name,
    FolderIcon icon = FolderIcon.folder,
    String? parentId,
    String? color,
  }) async {
    if (_userId == null) return;

    final currentFolders = state.value ?? [];
    final newSortOrder = currentFolders.length;
    final parentFolder = parentId != null
        ? currentFolders.where((f) => f.id == parentId).firstOrNull
        : null;
    final depth = parentFolder != null ? parentFolder.depth + 1 : 0;

    // Check max depth
    if (depth >= kMaxFolderDepth) {
      throw Exception('Maximum folder depth reached');
    }

    final folderId = _uuid.v4();
    final folder = TemplateFolder(
      id: folderId,
      userId: _userId!,
      name: name,
      parentId: parentId,
      icon: icon,
      color: color,
      sortOrder: newSortOrder,
      depth: depth,
      createdAt: DateTime.now(),
    );

    state = const AsyncValue.loading();

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('template_folders')
          .doc(folderId)
          .set(folder.toJson());

      state = AsyncValue.data([...currentFolders, folder]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update folder properties
  Future<void> updateFolder(
    String folderId, {
    String? name,
    FolderIcon? icon,
    String? color,
  }) async {
    if (_userId == null) return;

    final currentFolders = state.value ?? [];
    final folderIndex = currentFolders.indexWhere((f) => f.id == folderId);
    if (folderIndex == -1) return;

    final folder = currentFolders[folderIndex];
    final updatedFolder = folder.copyWith(
      name: name ?? folder.name,
      icon: icon ?? folder.icon,
      color: color,
      updatedAt: DateTime.now(),
    );

    state = const AsyncValue.loading();

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('template_folders')
          .doc(folderId)
          .update({
            if (name != null) 'name': name,
            if (icon != null) 'icon': icon.name,
            if (color != null) 'color': color,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      final newFolders = [...currentFolders];
      newFolders[folderIndex] = updatedFolder;
      state = AsyncValue.data(newFolders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update folder sort order
  Future<void> updateSortOrder(String folderId, int newOrder) async {
    if (_userId == null) return;

    final currentFolders = state.value ?? [];
    final folderIndex = currentFolders.indexWhere((f) => f.id == folderId);
    if (folderIndex == -1) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('template_folders')
          .doc(folderId)
          .update({
            'sortOrder': newOrder,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Reload to get correct order
      state = AsyncValue.data(await _loadFolders());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a folder
  Future<void> deleteFolder(String folderId) async {
    if (_userId == null) return;

    final currentFolders = state.value ?? [];

    state = const AsyncValue.loading();

    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('template_folders')
          .doc(folderId)
          .delete();

      // Remove templates from this folder (set folderId to null)
      final templatesInFolder = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('coach_templates')
          .where('folderId', isEqualTo: folderId)
          .get();

      final batch = _firestore.batch();
      for (final doc in templatesInFolder.docs) {
        batch.update(doc.reference, {'folderId': FieldValue.delete()});
      }
      await batch.commit();

      state = AsyncValue.data(
        currentFolders.where((f) => f.id != folderId).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
