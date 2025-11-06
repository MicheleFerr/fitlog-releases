import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/timer_sound.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class TimerSoundSelector extends ConsumerWidget {
  
  const TimerSoundSelector({
    super.key,
    required this.selectedSound,
    required this.onSoundSelected,
  });
  final TimerSound selectedSound;
  final Function(TimerSound) onSoundSelected;
  
  // Player statico per evitare conflitti
  static AudioPlayer? _previewPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSound = selectedSound;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: TimerSound.allSounds.map((sound) => _buildSoundOption(
        context,
        ref,
        sound,
        isSelected: sound == currentSound,
      )).toList(),
    );
  }

  Widget _buildSoundOption(
    BuildContext context,
    WidgetRef ref,
    TimerSound sound,
    {required bool isSelected}
  ) {
    return RadioListTile<TimerSound>(
      title: Text(sound.displayName),
      value: sound,
      groupValue: selectedSound,
      onChanged: (value) {
        if (value != null) {
          onSoundSelected(value);
        }
      },
      secondary: IconButton(
        onPressed: () => _playPreview(context, sound),
        icon: const Icon(AppIcons.play, size: 20),
        tooltip: AppLocalizations.of(context).playPreview,
      ),
    );
  }


  Future<bool> _checkAssetExists(String path) async {
    try {
      await rootBundle.load('assets/$path');
      return true;
    } catch (e) {
      // print('❌ Asset non trovato: assets/$path');
      return false;
    }
  }

  void _playPreview(BuildContext context, TimerSound sound) async {
    try {
      // Ferma eventuali preview precedenti
      await _previewPlayer?.stop();
      await _previewPlayer?.dispose();
      
      final audioPath = 'sounds/${sound.fileName}.wav';
      // print('🎵 Tentativo riproduzione: $audioPath');
      
      // Verifica se il file esiste
      final exists = await _checkAssetExists(audioPath);
      if (!exists) {
        throw Exception('File audio non trovato: $audioPath');
      }
      
      _previewPlayer = AudioPlayer();
      await _previewPlayer!.play(AssetSource(audioPath));
      
      // Show feedback
      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          '🔊 ${sound.displayName}',
          duration: const Duration(seconds: 1),
        );
      }
      
      // Auto-stop dopo 3 secondi
      Future.delayed(const Duration(seconds: 3), () async {
        await _previewPlayer?.stop();
      });
      
    } catch (e) {
      // Debug: mostra errore dettagliato
      // print('❌ Errore audio: $e');
      
      // Handle error con dettagli specifici
      if (context.mounted) {
        SnackBarService.showError(
          context,
          '❌ ${sound.displayName}\n${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
}
