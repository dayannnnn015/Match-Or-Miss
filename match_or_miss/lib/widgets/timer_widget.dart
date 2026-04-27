// ============================================================================
// TIMER WIDGET - ELEGANT COUNTDOWN
// ============================================================================
// lib/widgets/timer_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});
  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _elapsed = 0;

  @override
  void initState() { super.initState(); _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => _elapsed++); }); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final mode = gp.currentSession?.mode;
        if (mode == GameMode.quick) return const SizedBox.shrink();
        final color = mode == GameMode.standard ? const Color(0xFF6C63FF) : const Color(0xFFFF6584);
        final mins = (_elapsed ~/ 60).toString().padLeft(2, '0');
        final secs = (_elapsed % 60).toString().padLeft(2, '0');
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.access_time, size: 14, color: Color(0xFF6C63FF)),
            const SizedBox(width: 6),
            Text('$mins:$secs', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, fontFamily: 'monospace')),
          ]),
        );
      },
    );
  }
}