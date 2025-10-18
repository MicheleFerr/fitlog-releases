#!/usr/bin/env python3
"""
Script to add new localization keys to ARB files
"""

import json

# New keys to add (English)
new_keys_en = {
    "feedbackThankYou": "Thanks for your feedback!",
    "@feedbackThankYou": {
        "description": "Thank you message after user rates a questionnaire step"
    },
    "feedbackPrompt": "How was this step?",
    "@feedbackPrompt": {
        "description": "Prompt asking user to rate questionnaire step"
    },
    "feedbackQuestion": "Rate your experience with this step",
    "@feedbackQuestion": {
        "description": "Question asking user to provide feedback"
    },
    "feedbackPoor": "Poor",
    "@feedbackPoor": {
        "description": "Label for 1-star rating (poor)"
    },
    "feedbackExcellent": "Excellent",
    "@feedbackExcellent": {
        "description": "Label for 5-star rating (excellent)"
    },
    "staleProfileTitle": "Update Your Fitness Profile",
    "@staleProfileTitle": {
        "description": "Title for stale profile banner"
    },
    "staleProfileSubtitle1Month": "Your profile hasn't been updated in {days} days. Update it for more accurate suggestions!",
    "@staleProfileSubtitle1Month": {
        "description": "Subtitle when profile is 30-59 days old",
        "placeholders": {
            "days": {"type": "int"}
        }
    },
    "staleProfileSubtitleMonths": "Your profile is {months} months old. Time to update for better suggestions!",
    "@staleProfileSubtitleMonths": {
        "description": "Subtitle when profile is 2-5 months old",
        "placeholders": {
            "months": {"type": "int"}
        }
    },
    "staleProfileSubtitleManyMonths": "Your profile hasn't been updated in {months} months! Update now for accurate suggestions.",
    "@staleProfileSubtitleManyMonths": {
        "description": "Subtitle when profile is 6+ months old",
        "placeholders": {
            "months": {"type": "int"}
        }
    },
    "staleProfileUpdateButton": "Update",
    "@staleProfileUpdateButton": {
        "description": "Button text to update profile"
    }
}

# New keys to add (Italian)
new_keys_it = {
    "feedbackThankYou": "Grazie per il tuo feedback!",
    "@feedbackThankYou": {
        "description": "Thank you message after user rates a questionnaire step"
    },
    "feedbackPrompt": "Come è stato questo passaggio?",
    "@feedbackPrompt": {
        "description": "Prompt asking user to rate questionnaire step"
    },
    "feedbackQuestion": "Valuta la tua esperienza con questo passaggio",
    "@feedbackQuestion": {
        "description": "Question asking user to provide feedback"
    },
    "feedbackPoor": "Scarso",
    "@feedbackPoor": {
        "description": "Label for 1-star rating (poor)"
    },
    "feedbackExcellent": "Eccellente",
    "@feedbackExcellent": {
        "description": "Label for 5-star rating (excellent)"
    },
    "staleProfileTitle": "Aggiorna il Tuo Profilo Fitness",
    "@staleProfileTitle": {
        "description": "Title for stale profile banner"
    },
    "staleProfileSubtitle1Month": "Il tuo profilo non è stato aggiornato da {days} giorni. Aggiornalo per suggerimenti più precisi!",
    "@staleProfileSubtitle1Month": {
        "description": "Subtitle when profile is 30-59 days old",
        "placeholders": {
            "days": {"type": "int"}
        }
    },
    "staleProfileSubtitleMonths": "Il tuo profilo ha {months} mesi. È ora di aggiornarlo per suggerimenti migliori!",
    "@staleProfileSubtitleMonths": {
        "description": "Subtitle when profile is 2-5 months old",
        "placeholders": {
            "months": {"type": "int"}
        }
    },
    "staleProfileSubtitleManyMonths": "Il tuo profilo non è stato aggiornato da {months} mesi! Aggiornalo ora per suggerimenti accurati.",
    "@staleProfileSubtitleManyMonths": {
        "description": "Subtitle when profile is 6+ months old",
        "placeholders": {
            "months": {"type": "int"}
        }
    },
    "staleProfileUpdateButton": "Aggiorna",
    "@staleProfileUpdateButton": {
        "description": "Button text to update profile"
    }
}

def add_keys_to_arb(file_path, new_keys):
    """Add new keys to an ARB file"""
    try:
        # Read existing file
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Add new keys
        data.update(new_keys)

        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"✅ Successfully updated {file_path}")
        return True
    except Exception as e:
        print(f"❌ Error updating {file_path}: {e}")
        return False

# Main execution
if __name__ == "__main__":
    import sys

    en_file = "assets/i18n/app_en.arb"
    it_file = "assets/i18n/app_it.arb"

    success_en = add_keys_to_arb(en_file, new_keys_en)
    success_it = add_keys_to_arb(it_file, new_keys_it)

    if success_en and success_it:
        print("\n✅ All localization keys added successfully!")
        print("Run 'flutter gen-l10n' to generate the localization files")
        sys.exit(0)
    else:
        print("\n❌ Failed to add some localization keys")
        sys.exit(1)
