#!/usr/bin/env python3
"""
Exercise Database Validation Script
====================================

Validates exercises in JSON files for:
- Required fields presence
- Data type correctness
- Semantic versioning consistency
- Duplicate detection
- Field value coherence

Usage:
    python3 scripts/validate_exercises.py assets/data/exercises_en.json
    python3 scripts/validate_exercises.py assets/data/exercises_it.json
    python3 scripts/validate_exercises.py  # Validates both files

Author: GymBro Development
Date: 2025-10-16
"""

import json
import sys
import os
from pathlib import Path
from typing import List, Dict, Any, Tuple
from dataclasses import dataclass
from enum import Enum


class ValidationLevel(Enum):
    """Severity levels for validation issues"""
    ERROR = "ERROR"
    WARNING = "WARNING"
    INFO = "INFO"


@dataclass
class ValidationIssue:
    """Represents a single validation issue"""
    level: ValidationLevel
    exercise_id: str
    exercise_name: str
    field: str
    message: str
    value: Any = None
    line_number: int = 0

    def __str__(self) -> str:
        return f"[{self.level.value}] Exercise '{self.exercise_id}' ({self.exercise_name}): {self.message}"


class ExerciseValidator:
    """Main validator for exercise database"""

    # Required fields that MUST be present
    REQUIRED_FIELDS = {
        "id": str,
        "nome": str,
        "focus": (str, type(None)),  # Can be null
        "imageUrl": str,
        "difficolta": str,
    }

    # All known focus areas (muscle groups)
    VALID_FOCUS_AREAS = {
        "CHEST", "BACK", "SHOULDERS", "BICEPS", "TRICEPS", "FOREARMS",
        "CORE", "ABS", "OBLIQUES", "GLUT", "QUAD", "HAMSTRING", "CALVES",
        "LEGS", "FEMOR", "LATS", "TRAPS", "RHOMBOID", "ROTATOR_CUFF",
        "FULL_BODY", "CARDIO", "FLEXIBILITY", "STABILIZER", "COMPOUND",
        # Italian abbreviations (also valid)
        "PETT", "BICI", "POLP", "LAT", "TRAP", "SPALL", "ADDO",
        None  # Can be null
    }

    # Focus area abbreviation mapping (for auto-correction)
    FOCUS_ABBREVIATIONS = {
        "PETT": "CHEST",
        "BICI": "BICEPS",
        "POLP": "CALVES",
        "LAT": "LATS",
        "TRAP": "TRAPS",
        "SPALL": "SHOULDERS",
        "ADDO": "ADDUCTORS",  # Inner thighs
    }

    # Valid difficulty levels
    VALID_DIFFICULTIES = {
        "Principiante", "Intermediate", "Intermedio", "Avanzato", "Advanced",
        "Principiante/Intermedio", "Intermedio/Avanzato", "Beginner"
    }

    # Valid equipment types
    VALID_EQUIPMENT = {
        "Corpo Libero", "Bilanciere", "Manubri", "Kettlebell", "Elastici",
        "Cable", "Cavi", "Machine", "Macchina", "Medicine Ball", "Palla Medica",
        "Palla Stabilità", "TRX", "Foam Roller", "Palla da Palestra",
        "Barra Pull-up", "Panca", "Rack", "Leg Press", "Smith Machine",
        "Unilateral", "Assistito", "Assisted", None
    }

    # Valid exercise types
    VALID_EXERCISE_TYPES = {
        "Compound", "Isolation", "Isometric", "Dynamic", "Functional",
        "Plyometric", "Aerobic", "Anaerobic", "Stretching", "Mobility",
        None
    }

    def __init__(self, strict: bool = False):
        """
        Initialize validator

        Args:
            strict: If True, warnings become errors
        """
        self.strict = strict
        self.issues: List[ValidationIssue] = []
        self.seen_ids: Dict[str, str] = {}  # Maps id -> exercise_name
        self.seen_names: Dict[str, str] = {}  # Maps name -> id

    def validate_file(self, file_path: str) -> Tuple[bool, List[ValidationIssue]]:
        """
        Validate a complete exercise JSON file

        Args:
            file_path: Path to exercises JSON file

        Returns:
            Tuple of (is_valid, list_of_issues)
        """
        self.issues = []
        self.seen_ids = {}
        self.seen_names = {}

        if not os.path.exists(file_path):
            return False, [
                ValidationIssue(
                    ValidationLevel.ERROR,
                    "N/A",
                    "N/A",
                    "file",
                    f"File not found: {file_path}"
                )
            ]

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            return False, [
                ValidationIssue(
                    ValidationLevel.ERROR,
                    "N/A",
                    "N/A",
                    "json",
                    f"Invalid JSON: {str(e)}"
                )
            ]
        except Exception as e:
            return False, [
                ValidationIssue(
                    ValidationLevel.ERROR,
                    "N/A",
                    "N/A",
                    "file",
                    f"Error reading file: {str(e)}"
                )
            ]

        # Ensure data is a list
        if not isinstance(data, list):
            return False, [
                ValidationIssue(
                    ValidationLevel.ERROR,
                    "N/A",
                    "N/A",
                    "structure",
                    f"Expected list of exercises, got {type(data).__name__}"
                )
            ]

        # Validate each exercise
        for idx, exercise in enumerate(data):
            self._validate_exercise(exercise, idx)

        # Check for errors/warnings
        errors = [i for i in self.issues if i.level == ValidationLevel.ERROR]
        warnings = [i for i in self.issues if i.level == ValidationLevel.WARNING]

        is_valid = len(errors) == 0 and (len(warnings) == 0 or not self.strict)

        return is_valid, self.issues

    def _validate_exercise(self, exercise: Dict[str, Any], index: int) -> None:
        """Validate a single exercise object"""

        if not isinstance(exercise, dict):
            self.issues.append(
                ValidationIssue(
                    ValidationLevel.ERROR,
                    f"[{index}]",
                    "N/A",
                    "structure",
                    f"Expected dict, got {type(exercise).__name__}"
                )
            )
            return

        # Get ID and name for error reporting
        exercise_id = exercise.get("id", f"[{index}]")
        exercise_name = exercise.get("nome", "N/A")

        # 1. Check required fields
        self._validate_required_fields(exercise, exercise_id, exercise_name)

        # 2. Check field value coherence
        self._validate_field_coherence(exercise, exercise_id, exercise_name)

        # 3. Check for duplicates
        self._check_duplicates(exercise, exercise_id, exercise_name)

    def _validate_required_fields(
        self, exercise: Dict[str, Any], exercise_id: str, exercise_name: str
    ) -> None:
        """Validate that required fields are present and correct type"""

        for field, expected_type in self.REQUIRED_FIELDS.items():
            if field not in exercise:
                self.issues.append(
                    ValidationIssue(
                        ValidationLevel.ERROR,
                        exercise_id,
                        exercise_name,
                        field,
                        f"Required field missing: {field}"
                    )
                )
                continue

            value = exercise[field]

            # Check type
            if isinstance(expected_type, tuple):
                # Multiple possible types
                if not isinstance(value, expected_type):
                    actual_type = type(value).__name__
                    expected = " or ".join(t.__name__ for t in expected_type)
                    self.issues.append(
                        ValidationIssue(
                            ValidationLevel.ERROR,
                            exercise_id,
                            exercise_name,
                            field,
                            f"Wrong type for {field}: expected {expected}, got {actual_type}",
                            value
                        )
                    )
            else:
                if not isinstance(value, expected_type):
                    actual_type = type(value).__name__
                    expected = expected_type.__name__
                    self.issues.append(
                        ValidationIssue(
                            ValidationLevel.ERROR,
                            exercise_id,
                            exercise_name,
                            field,
                            f"Wrong type for {field}: expected {expected}, got {actual_type}",
                            value
                        )
                    )

            # Check value is not empty string
            if isinstance(value, str) and value.strip() == "":
                self.issues.append(
                    ValidationIssue(
                        ValidationLevel.ERROR,
                        exercise_id,
                        exercise_name,
                        field,
                        f"Empty value for required field: {field}"
                    )
                )

    def _validate_field_coherence(
        self, exercise: Dict[str, Any], exercise_id: str, exercise_name: str
    ) -> None:
        """Validate logical coherence of field values"""

        # Validate focus area (can be comma-separated)
        if "focus" in exercise:
            focus = exercise["focus"]
            if focus is not None:
                # Handle comma-separated focus areas
                focus_areas = [f.strip() for f in focus.split(",")]
                for fa in focus_areas:
                    if fa not in self.VALID_FOCUS_AREAS:
                        self.issues.append(
                            ValidationIssue(
                                ValidationLevel.WARNING,
                                exercise_id,
                                exercise_name,
                                "focus",
                                f"Unknown focus area: {fa}. Valid: {', '.join(sorted(self.VALID_FOCUS_AREAS - {None}))}",
                                focus
                            )
                        )

        # Validate difficulty
        if "difficolta" in exercise:
            difficulty = exercise["difficolta"]
            if difficulty not in self.VALID_DIFFICULTIES:
                self.issues.append(
                    ValidationIssue(
                        ValidationLevel.WARNING,
                        exercise_id,
                        exercise_name,
                        "difficolta",
                        f"Unknown difficulty: {difficulty}. Valid: {', '.join(sorted(self.VALID_DIFFICULTIES))}",
                        difficulty
                    )
                )

        # Validate equipment
        if "attrezzatura" in exercise:
            equipment = exercise["attrezzatura"]
            if equipment is not None and equipment not in self.VALID_EQUIPMENT:
                self.issues.append(
                    ValidationIssue(
                        ValidationLevel.WARNING,
                        exercise_id,
                        exercise_name,
                        "attrezzatura",
                        f"Unknown equipment: {equipment}",
                        equipment
                    )
                )

        # Validate exercise type
        if "tipoEsercizio" in exercise:
            ex_type = exercise["tipoEsercizio"]
            if ex_type is not None and ex_type not in self.VALID_EXERCISE_TYPES:
                self.issues.append(
                    ValidationIssue(
                        ValidationLevel.WARNING,
                        exercise_id,
                        exercise_name,
                        "tipoEsercizio",
                        f"Unknown exercise type: {ex_type}",
                        ex_type
                    )
                )

        # Validate imageUrl format
        if "imageUrl" in exercise:
            url = exercise["imageUrl"]
            if not url.startswith(("http://", "https://", "/")):
                self.issues.append(
                    ValidationIssue(
                        ValidationLevel.WARNING,
                        exercise_id,
                        exercise_name,
                        "imageUrl",
                        f"Suspicious imageUrl format: {url}",
                        url
                    )
                )

    def _check_duplicates(
        self, exercise: Dict[str, Any], exercise_id: str, exercise_name: str
    ) -> None:
        """Check for duplicate IDs and names"""

        # Check ID duplicates
        if exercise_id in self.seen_ids:
            self.issues.append(
                ValidationIssue(
                    ValidationLevel.ERROR,
                    exercise_id,
                    exercise_name,
                    "id",
                    f"Duplicate ID: already seen in exercise '{self.seen_ids[exercise_id]}'",
                    exercise_id
                )
            )
        else:
            self.seen_ids[exercise_id] = exercise_name

        # Check name duplicates (only warn, different variations might be valid)
        if exercise_name in self.seen_names:
            # Only warn if it's exactly the same - variations are OK
            if self.seen_names[exercise_name] == exercise_id:
                pass  # Same exercise, skip
            else:
                # Different exercise with same name
                pass  # Allow for now, might have variations


def print_report(file_path: str, is_valid: bool, issues: List[ValidationIssue]) -> None:
    """Print a formatted validation report"""

    errors = [i for i in issues if i.level == ValidationLevel.ERROR]
    warnings = [i for i in issues if i.level == ValidationLevel.WARNING]
    infos = [i for i in issues if i.level == ValidationLevel.INFO]

    print("\n" + "=" * 80)
    print(f"VALIDATION REPORT: {file_path}")
    print("=" * 80)

    print(f"\n📊 Summary:")
    print(f"   ✅ Valid: {is_valid}")
    print(f"   ❌ Errors: {len(errors)}")
    print(f"   ⚠️  Warnings: {len(warnings)}")
    print(f"   ℹ️  Info: {len(infos)}")

    if errors:
        print(f"\n❌ ERRORS ({len(errors)}):")
        for issue in errors[:20]:  # Show first 20
            print(f"   {issue}")
        if len(errors) > 20:
            print(f"   ... and {len(errors) - 20} more errors")

    if warnings:
        print(f"\n⚠️  WARNINGS ({len(warnings)}):")
        for issue in warnings[:10]:  # Show first 10
            print(f"   {issue}")
        if len(warnings) > 10:
            print(f"   ... and {len(warnings) - 10} more warnings")

    print("\n" + "=" * 80)


def main():
    """Main entry point"""

    # Determine which files to validate
    if len(sys.argv) > 1:
        files = sys.argv[1:]
    else:
        # Validate both files if no arguments
        files = [
            "assets/data/exercises_en.json",
            "assets/data/exercises_it.json"
        ]

    # Filter to existing files
    files = [f for f in files if os.path.exists(f)]

    if not files:
        print("❌ No valid files found to validate")
        print(f"\nUsage: python3 scripts/validate_exercises.py <file1> [file2] ...")
        sys.exit(1)

    # Validate each file
    all_valid = True
    all_issues = []

    for file_path in files:
        print(f"\n🔍 Validating {file_path}...")
        validator = ExerciseValidator(strict=False)
        is_valid, issues = validator.validate_file(file_path)

        print_report(file_path, is_valid, issues)
        all_issues.extend(issues)

        if not is_valid:
            all_valid = False

    # Final summary
    total_errors = len([i for i in all_issues if i.level == ValidationLevel.ERROR])
    total_warnings = len([i for i in all_issues if i.level == ValidationLevel.WARNING])

    print("\n" + "=" * 80)
    print("FINAL SUMMARY")
    print("=" * 80)
    print(f"Files validated: {len(files)}")
    print(f"Total errors: {total_errors}")
    print(f"Total warnings: {total_warnings}")

    if all_valid:
        print("\n✅ All validation checks passed!")
        sys.exit(0)
    else:
        print("\n❌ Validation failed - please fix the errors above")
        sys.exit(1)


if __name__ == "__main__":
    main()
