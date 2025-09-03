import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class WorkoutShareSummary extends ConsumerStatefulWidget {
  final Workout workout;
  
  const WorkoutShareSummary({
    super.key,
    required this.workout,
  });
  
  static Future<void> show(BuildContext context, Workout workout) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutShareSummary(workout: workout),
    );
  }

  @override
  ConsumerState<WorkoutShareSummary> createState() => _WorkoutShareSummaryState();
}

class _WorkoutShareSummaryState extends ConsumerState<WorkoutShareSummary> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  File? _backgroundImage;
  bool _isGenerating = false;
  bool _showSelfieOption = true;
  
  // Calculate workout stats
  int get totalExercises => widget.workout.exercises.where((e) => e.isCompleted).length;
  
  double get totalVolume {
    double volume = 0;
    for (final exercise in widget.workout.exercises) {
      if (exercise.isCompleted) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            final weight = set.weight ?? 0;
            final reps = set.reps ?? 0;
            volume += weight * reps;
          }
        }
      }
    }
    return volume;
  }
  
  String get workoutDuration {
    if (widget.workout.startTime == null || widget.workout.endTime == null) {
      return '00:00';
    }
    final duration = widget.workout.endTime!.difference(widget.workout.startTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _backgroundImage = File(image.path);
          _showSelfieOption = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPickingImage(e.toString()))),
        );
      }
    }
  }
  
  Future<void> _generateAndShare() async {
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Capture the widget as image
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/workout_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        // Share the image
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '💪 Just crushed my workout with FitLogPro! '
              '${totalExercises} exercises, ${totalVolume.toStringAsFixed(0)}kg total volume, '
              '${workoutDuration} duration. #FitLogPro #GymLife #Fitness',
        );
        
        // Close the modal after sharing
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSharing(e.toString()))),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Your Achievement',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Preview area
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Shareable image preview
                      RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Container(
                          width: double.infinity,
                          height: 600,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background image or gradient
                                if (_backgroundImage != null)
                                  Image.file(
                                    _backgroundImage!,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.blue.shade900,
                                          Colors.purple.shade900,
                                        ],
                                      ),
                                    ),
                                  ),
                                
                                // Dark overlay for better text visibility
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Content overlay
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Logo and app name
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.fitness_center,
                                              color: Colors.blue,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'FitLogPro',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      const Spacer(),
                                      
                                      // Workout name
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          widget.workout.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Stats
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatColumn(
                                            icon: Icons.fitness_center,
                                            value: totalExercises.toString(),
                                            label: 'Exercises',
                                          ),
                                          _buildStatColumn(
                                            icon: Icons.monitor_weight,
                                            value: '${(totalVolume / 1000).toStringAsFixed(1)}',
                                            label: 'Tons',
                                          ),
                                          _buildStatColumn(
                                            icon: Icons.timer,
                                            value: workoutDuration,
                                            label: 'Duration',
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 32),
                                      
                                      // Motivational quote
                                      Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.format_quote,
                                              color: Colors.white.withValues(alpha: 0.5),
                                              size: 30,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'WORKOUT COMPLETE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black.withValues(alpha: 0.5),
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'One step closer to your goals!',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Image selection buttons (only show if no image selected)
                      if (_showSelfieOption) ...[
                        Text(
                          'Add a background photo',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageButton(
                              icon: Icons.camera_alt,
                              label: 'Take Selfie',
                              onTap: () => _pickImage(ImageSource.camera),
                              theme: theme,
                            ),
                            _buildImageButton(
                              icon: Icons.photo_library,
                              label: 'Choose Photo',
                              onTap: () => _pickImage(ImageSource.gallery),
                              theme: theme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Change photo button (show if image is selected)
                      if (_backgroundImage != null) ...[
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _backgroundImage = null;
                              _showSelfieOption = true;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Change Background'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isGenerating ? null : _generateAndShare,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share),
                          label: Text(_isGenerating ? 'Generating...' : 'Share Achievement'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}