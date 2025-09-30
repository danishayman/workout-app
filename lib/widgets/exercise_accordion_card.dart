import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../providers/session_providers.dart';

class ExerciseAccordionCard extends StatefulWidget {
  final SelectedExercise exercise;
  final int exerciseIndex;
  final Function(int, SelectedExercise) onUpdateExercise;
  final Function(int) onToggleExpansion;
  final Function(int) onAddSet;
  final Function(int, int, ExerciseSet) onUpdateSet;
  final Function(int, String) onUpdateNotes;
  final VoidCallback onRemove;

  const ExerciseAccordionCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onUpdateExercise,
    required this.onToggleExpansion,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onUpdateNotes,
    required this.onRemove,
  });

  @override
  State<ExerciseAccordionCard> createState() => _ExerciseAccordionCardState();
}

class _ExerciseAccordionCardState extends State<ExerciseAccordionCard> {
  Timer? _restTimer;
  Duration _restDuration = Duration.zero;
  bool _isResting = false;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restDuration = const Duration(
        minutes: 1,
        seconds: 30,
      ); // Default 1:30 rest
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_restDuration.inSeconds > 0) {
            _restDuration = Duration(seconds: _restDuration.inSeconds - 1);
          } else {
            _restTimer?.cancel();
            _isResting = false;
          }
        });
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restDuration = Duration.zero;
    });
  }

  String _formatRestTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}min ${seconds}s';
  }

  int _getCompletedSets() {
    return widget.exercise.exerciseSets.where((set) => set.completed).length;
  }

  Widget _buildExerciseHeader() {
    final completedSets = _getCompletedSets();
    final totalSets = widget.exercise.exerciseSets.length;

    return InkWell(
      onTap: () => widget.onToggleExpansion(widget.exerciseIndex),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            // Exercise Image Placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Exercise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.workout.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedSets/$totalSets done',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),

            // More Options Button
            IconButton(
              onPressed: () {
                // TODO: Show exercise options menu
              },
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (!widget.exercise.isExpanded) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes Section
          TextField(
            controller: _notesController,
            onChanged: (value) =>
                widget.onUpdateNotes(widget.exerciseIndex, value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Notes...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: null,
          ),

          const SizedBox(height: 16),

          // Rest Timer
          if (_isResting) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Rest Timer: ${_formatRestTime(_restDuration)}',
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _stopRestTimer,
                    child: const Icon(
                      Icons.close,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Sets Header
          const Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'Set',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Previous',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'Kg',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  'Reps',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 8),

          // Sets List
          ...widget.exercise.exerciseSets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return _buildSetRow(index, set);
          }).toList(),

          const SizedBox(height: 16),

          // Add Set Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onAddSet(widget.exerciseIndex),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('+ Add Set'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int setIndex, ExerciseSet set) {
    final setNumber = setIndex + 1;
    final previousSet = setIndex > 0
        ? widget.exercise.exerciseSets[setIndex - 1]
        : null;
    final previousText = previousSet != null
        ? '${previousSet.weight?.toStringAsFixed(1) ?? '0'} kg x ${previousSet.reps}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: set.completed ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: set.completed ? Colors.blue : Colors.grey[600]!,
                ),
              ),
              child: Text(
                setNumber.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: set.completed ? Colors.white : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Previous Set Info
          SizedBox(
            width: 80,
            child: Text(
              previousText,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),

          // Weight Input
          SizedBox(
            width: 80,
            child: TextField(
              controller: TextEditingController(
                text: set.weight?.toStringAsFixed(1) ?? '',
              ),
              onChanged: (value) {
                final weight = double.tryParse(value);
                final updatedSet = set.copyWith(weight: weight);
                widget.onUpdateSet(widget.exerciseIndex, setIndex, updatedSet);
              },
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: '19.5',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),

          // Reps Input
          SizedBox(
            width: 60,
            child: TextField(
              controller: TextEditingController(text: set.reps.toString()),
              onChanged: (value) {
                final reps = int.tryParse(value) ?? set.reps;
                final updatedSet = set.copyWith(reps: reps);
                widget.onUpdateSet(widget.exerciseIndex, setIndex, updatedSet);
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: '8',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),

          // Complete Set Checkbox
          SizedBox(
            width: 40,
            child: GestureDetector(
              onTap: () {
                final updatedSet = set.copyWith(completed: !set.completed);
                widget.onUpdateSet(widget.exerciseIndex, setIndex, updatedSet);

                // Start rest timer when completing a set
                if (!set.completed && updatedSet.completed && !_isResting) {
                  _startRestTimer();
                }
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: set.completed ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: set.completed ? Colors.green : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child: set.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildExerciseHeader(), _buildExpandedContent()]);
  }
}
