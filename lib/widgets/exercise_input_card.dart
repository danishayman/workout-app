import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/session_providers.dart';

class ExerciseInputCard extends StatefulWidget {
  final SelectedExercise exercise;
  final Function(SelectedExercise) onUpdate;
  final VoidCallback onRemove;

  const ExerciseInputCard({
    super.key,
    required this.exercise,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<ExerciseInputCard> createState() => _ExerciseInputCardState();
}

class _ExerciseInputCardState extends State<ExerciseInputCard> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: widget.exercise.sets.toString(),
    );
    _repsController = TextEditingController(
      text: widget.exercise.reps.toString(),
    );
    _weightController = TextEditingController(
      text: widget.exercise.weight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.workout.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            widget.exercise.workout.category,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCategoryColor(
                              widget.exercise.workout.category,
                            ).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          widget.exercise.workout.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(
                              widget.exercise.workout.category,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.withOpacity(0.7),
                ),
              ],
            ),

            if (widget.exercise.workout.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.exercise.workout.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Input Fields
            Row(
              children: [
                // Sets Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sets',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _onSetsChanged,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Reps Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reps',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _onRepsChanged,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Weight Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight (kg)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        onChanged: _onWeightChanged,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          hintText: 'Optional',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Action Buttons
            Row(
              children: [
                // Sets buttons
                Text(
                  'Quick Sets: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                _buildQuickButton('1', () => _updateSets(1)),
                _buildQuickButton('3', () => _updateSets(3)),
                _buildQuickButton('5', () => _updateSets(5)),

                const SizedBox(width: 16),

                // Reps buttons
                Text(
                  'Quick Reps: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                _buildQuickButton('10', () => _updateReps(10)),
                _buildQuickButton('12', () => _updateReps(12)),
                _buildQuickButton('15', () => _updateReps(15)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  void _onSetsChanged(String value) {
    final sets = int.tryParse(value) ?? 1;
    _updateExercise(sets: sets);
  }

  void _onRepsChanged(String value) {
    final reps = int.tryParse(value) ?? 1;
    _updateExercise(reps: reps);
  }

  void _onWeightChanged(String value) {
    final weight = value.isEmpty ? null : double.tryParse(value);
    _updateExercise(weight: weight);
  }

  void _updateSets(int sets) {
    _setsController.text = sets.toString();
    _updateExercise(sets: sets);
  }

  void _updateReps(int reps) {
    _repsController.text = reps.toString();
    _updateExercise(reps: reps);
  }

  void _updateExercise({int? sets, int? reps, double? weight}) {
    final updatedExercise = widget.exercise.copyWith(
      sets: sets,
      reps: reps,
      weight: weight,
    );
    widget.onUpdate(updatedExercise);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.blue;
      case 'legs':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.purple;
      case 'core':
        return Colors.yellow;
      case 'cardio':
        return Colors.pink;
      case 'full body':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
