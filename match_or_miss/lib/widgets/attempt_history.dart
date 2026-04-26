// lib/widgets/attempt_history.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';

class AttemptHistory extends StatelessWidget {
  const AttemptHistory({
    super.key,
    required this.attempts,
    this.isVisible = true,
  });

  final List<Attempt> attempts;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    if (attempts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Your move history will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.history, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              const Text(
                'MOVE HISTORY',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Legend
              _legendDot(Colors.greenAccent, '✓ correct position'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: attempts.length,
            // Show newest at top
            itemBuilder: (context, index) {
              final attempt = attempts[attempts.length - 1 - index];
              final isLatest = index == 0;
              return _buildAttemptRow(attempt, isLatest);
            },
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildAttemptRow(Attempt attempt, bool isLatest) {
    final matchCount = attempt.matches;
    final total = AppConstants.sequenceLength;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isLatest
            ? Colors.white.withOpacity(0.07)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Move number
          SizedBox(
            width: 28,
            child: Text(
              '#${attempt.attemptNumber}',
              style: TextStyle(
                color: isLatest ? Colors.white70 : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bottle row with match indicators
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final bottle = attempt.guess[i];
                final isMatched = attempt.matchedPositions.contains(i);
                return _buildBottleCell(bottle, isMatched);
              }),
            ),
          ),

          // Match count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _badgeColor(matchCount, total).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _badgeColor(matchCount, total).withOpacity(0.5),
              ),
            ),
            child: Text(
              '$matchCount/$total',
              style: TextStyle(
                color: _badgeColor(matchCount, total),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottleCell(Bottle? bottle, bool isMatched) {
    if (bottle == null) {
      return Container(
        width: 26,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24, width: 1),
        ),
      );
    }

    return Container(
      width: 26,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bottle.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isMatched ? Colors.greenAccent : Colors.white24,
          width: isMatched ? 2 : 1,
        ),
        boxShadow: isMatched
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: isMatched
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }

  Color _badgeColor(int matches, int total) {
    if (matches == total) return Colors.greenAccent;
    if (matches >= total * 0.6) return Colors.lightGreenAccent;
    if (matches >= total * 0.3) return Colors.orange;
    return Colors.redAccent;
  }
}