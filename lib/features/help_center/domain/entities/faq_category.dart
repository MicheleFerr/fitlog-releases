/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/help_center/domain/entities
/// 🎯 Feature: help_center
/// 🔧 Type: entity
///
/// FAQ Category - represents a help category with questions
library;

import 'package:flutter/material.dart';

/// FAQ Category with list of questions
class FAQCategory {
  const FAQCategory({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.items,
  });

  final String id;
  final String titleKey; // l10n key
  final String descriptionKey; // l10n key
  final IconData icon;
  final List<FAQItem> items;
}

/// Single FAQ question/answer pair
class FAQItem {
  const FAQItem({
    required this.id,
    required this.questionKey,
    required this.answerKey,
  });

  final String id;
  final String questionKey; // l10n key
  final String answerKey; // l10n key
}

/// Predefined FAQ categories
enum FAQCategoryType { appUsage, workouts, progress, settings }
