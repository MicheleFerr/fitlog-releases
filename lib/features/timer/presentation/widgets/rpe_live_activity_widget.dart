import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/live_activity_provider.dart';
import 'package:flutter/foundation.dart';

/// Widget per RPE Live Activity senza ombreggiature
class RPELiveActivityWidget extends ConsumerStatefulWidget {
  
  const RPELiveActivityWidget({
    super.key,
    required this.rpeData,
    required this.activityId,
  });
  final RPELiveActivityData rpeData;
  final String activityId;

  @override
  ConsumerState<RPELiveActivityWidget> createState() => _RPELiveActivityWidgetState();
}

class _RPELiveActivityWidgetState extends ConsumerState<RPELiveActivityWidget> {
  int? _selectedRPE;
  int? _actualReps;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _actualReps = widget.rpeData.targetReps; // Default alle reps target
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        // ✅ NESSUNA OMBREGGIATURA come richiesto
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildRepsSelector(),
          const SizedBox(height: 20),
          _buildRPESelector(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          '💪 Set Completato!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.rpeData.exerciseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${widget.rpeData.weight}kg • Set ${widget.rpeData.currentSet}/${widget.rpeData.totalSets}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRepsSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '🔢 Reps Effettive',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRepsButton(
                icon: Icons.remove,
                onPressed: _actualReps != null && _actualReps! > 1
                    ? () => setState(() => _actualReps = _actualReps! - 1)
                    : null,
              ),
              const SizedBox(width: 20),
              Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${_actualReps ?? widget.rpeData.targetReps}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildRepsButton(
                icon: Icons.add,
                onPressed: _actualReps != null && _actualReps! < 50
                    ? () => setState(() => _actualReps = _actualReps! + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepsButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: onPressed != null 
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            color: onPressed != null 
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRPESelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '⚡ RPE (Rate of Perceived Exertion)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quanto è stato difficile questo set?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(6, (index) {
              final rpe = index + 5; // RPE 5-10
              final isSelected = _selectedRPE == rpe;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedRPE = rpe),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$rpe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getRPEDescription(_selectedRPE),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canConfirm = _selectedRPE != null && _actualReps != null;
    
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Annulla',
            icon: Icons.close,
            color: Colors.white.withValues(alpha: 0.2),
            textColor: Colors.white,
            onPressed: _isLoading ? null : _handleCancel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildActionButton(
            label: _isLoading ? 'Salvando...' : 'Conferma Set',
            icon: _isLoading ? null : Icons.check,
            color: canConfirm 
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.3),
            textColor: canConfirm 
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.7),
            onPressed: canConfirm && !_isLoading ? _handleConfirm : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    IconData? icon,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 18),
                  const SizedBox(width: 8),
                ],
                if (_isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRPEDescription(int? rpe) {
    if (rpe == null) return 'Seleziona la difficoltà del set';
    
    switch (rpe) {
      case 5:
        return 'Molto leggero - Potevi fare molte reps in più';
      case 6:
        return 'Leggero - Circa 3-4 reps in riserva';
      case 7:
        return 'Moderato - Circa 2-3 reps in riserva';
      case 8:
        return 'Impegnativo - Circa 1-2 reps in riserva';
      case 9:
        return 'Molto impegnativo - Forse 1 rep in riserva';
      case 10:
        return 'Massimale - Nessuna rep in riserva';
      default:
        return '';
    }
  }

  Future<void> _handleConfirm() async {
    if (_selectedRPE == null || _actualReps == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final liveActivityService = ref.read(liveActivityProvider);
      
      await liveActivityService.confirmRPEAndCompleteSet(
        activityId: widget.activityId,
        actualReps: _actualReps!,
        rpe: _selectedRPE!,
        notes: null, // TODO: Aggiungere note se necessario
      );
      
      if (kDebugMode) {
        debugPrint('✅ RPE confermato: $_actualReps reps, RPE: $_selectedRPE');
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore confermando RPE: $e');
      }
      // TODO: Mostrare errore all'utente
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleCancel() async {
    try {
      final liveActivityService = ref.read(liveActivityProvider);
      
      await liveActivityService.dismissRPEInterface(
        activityId: widget.activityId,
      );
      
      if (kDebugMode) {
        debugPrint('❌ RPE cancellato dall\'utente');
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore cancellando RPE: $e');
      }
    }
  }
}

/// Widget compatto per Live Activity iOS (design semplificato)
class CompactRPELiveActivityWidget extends StatelessWidget {
  
  const CompactRPELiveActivityWidget({
    super.key,
    required this.rpeData,
  });
  final RPELiveActivityData rpeData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // ✅ NESSUNA OMBREGGIATURA
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('💪', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rpeData.exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Set ${rpeData.currentSet}/${rpeData.totalSets} • ${rpeData.weight}kg',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'RPE?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}