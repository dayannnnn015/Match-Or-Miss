import 'package:flutter/material.dart';
import '../models/game_models.dart';
import 'bottle_widget.dart';

/// A slot where bottles can be dropped
class BottleSlot extends StatefulWidget {
  final int index;
  final Bottle? bottle;
  final Function(int, Bottle) onBottleDropped;
  final VoidCallback? onBottleRemoved;
  final double size;
  final bool isEnabled;

  const BottleSlot({
    super.key,
    required this.index,
    this.bottle,
    required this.onBottleDropped,
    this.onBottleRemoved,
    this.size = 80,
    this.isEnabled = true,
  });

  @override
  State<BottleSlot> createState() => _BottleSlotState();
}

class _BottleSlotState extends State<BottleSlot> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Bottle>(
      onWillAcceptWithDetails: (details) => widget.isEnabled,
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        widget.onBottleDropped(widget.index, details.data);
      },
      onLeave: (_) {
        setState(() => _isDragOver = false);
      },
      onMove: (_) {
        if (!_isDragOver) {
          setState(() => _isDragOver = true);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: widget.size,
          height: widget.size * 1.3,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? Colors.cyanAccent : Colors.white30,
              width: _isDragOver ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _isDragOver
                ? Colors.cyanAccent.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            boxShadow: _isDragOver
                ? [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: widget.bottle != null
              ? Stack(
                  children: [
                    Center(
                      child: Draggable<Bottle>(
                        data: widget.bottle!,
                        feedback: Material(
                          color: Colors.transparent,
                          child: BottleWidget(
                            bottle: widget.bottle!,
                            size: widget.size,
                            isDragging: true,
                          ),
                        ),
                        childWhenDragging: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade600,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade800.withOpacity(0.5),
                          ),
                        ),
                        child: BottleWidget(
                          bottle: widget.bottle!,
                          size: widget.size,
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: widget.onBottleRemoved,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade600,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white30,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Slot ${widget.index + 1}',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
