library;

import 'package:flutter/widgets.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

String localizeTemplateErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final rawMessage = error
      .toString()
      .replaceFirst('TemplateQuotaExceededException: ', '')
      .replaceFirst('Exception: ', '')
      .trim();

  switch (rawMessage) {
    case 'Utente non autenticato':
    case 'User not authenticated':
      return l10n.errorUserNotAuthenticated;
    case 'Draft template not found after sync':
    case 'Forked template not found after sync':
    case 'Template non trovato':
    case 'Template not found':
      return l10n.templateNotFound;
    case 'Template condiviso non disponibile':
    case 'Shared template not available':
      return l10n.sharedTemplateUnavailable;
    case 'Shared template not found':
      return l10n.sharedTemplateNotFound;
    case 'Save this template to your Library before editing it.':
      return l10n.templateForkBeforeEdit;
    case 'Shared templates are read-only. Customize your copy before editing.':
    case 'Store and shared templates are read-only. Customize your copy before editing.':
      return l10n.sharedTemplateReadOnlyError;
    default:
      return rawMessage;
  }
}
