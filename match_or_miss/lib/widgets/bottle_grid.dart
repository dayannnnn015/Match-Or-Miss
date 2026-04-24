import 'package:flutter/material.dart';

import '../utils/constants.dart';

class BottleGrid extends StatelessWidget {
  const BottleGrid({
    super.key,
    required this.colors,
    required this.onColorTap,
    required this.onSwap,
    this.isEnabled = true,
  });

  final List<Color> colors;
  final void Function(int index, Color color) onColorTap;
  final void Function(int from, int to) onSwap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final itemCount = colors.isEmpty ? AppConstants.sequenceLength : colors.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final color = index < colors.length ? colors[index] : Colors.grey;

        return DragTarget<int>(
          onWillAcceptWithDetails: (_) => isEnabled,
          onAcceptWithDetails: (details) {
            if (details.data != index) {
              onSwap(details.data, index);
            }
          },
          builder: (context, _, __) {
            return Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: _buildBottle(color, isDragging: true),
              ),
              childWhenDragging: _buildBottle(Colors.grey.shade700),
              child: _buildBottle(
                color,
                onTap: isEnabled ? () => _showColorPicker(context, index) : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottle(Color color, {bool isDragging = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDragging ? Colors.white : Colors.white30,
            width: isDragging ? 3 : 2,
          ),
          boxShadow: isDragging
              ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bottle neck (2D flat style)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 20,
                height: 16,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
              ),
            ),
            // Main body with label
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.white.withOpacity(0.8),
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${color.value.toRadixString(16).substring(2, 8).toUpperCase().substring(0, 2)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, int index) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  onColorTap(index, color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
