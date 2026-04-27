// lib/screens/analysis_screen.dart - FIXED
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/ai_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  final AIService _ai = AIService();
  AIPlayerAnalysis? _analysis;
  bool _loading = true;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..forward();
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Fixed: await the Future and then assign
    final result = await _ai.analyzePlayerBehavior([]);
    if (mounted) {
      setState(() {
        _analysis = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A), Color(0xFF05050A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                      : _content(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6C63FF), size: 18),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'PERFORMANCE LAB',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
                ),
              ),
            ),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF), size: 18),
              ),
            ),
          ],
        ),
      );

  Widget _content() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassCard(
            child: Column(
              children: [
                const Text('COGNITIVE PROFILE', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _metric('EFFICIENCY', '74%', const Color(0xFF00D2FF)),
                    _metric('FOCUS', '82%', const Color(0xFF6C63FF)),
                    _metric('SPEED', '68%', const Color(0xFFFF6584)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Color(0xFFFFB347), size: 18),
                    SizedBox(width: 8),
                    Text('AI INSIGHTS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _insightItem('🎯', 'Lock in confirmed positions before experimenting with unknowns'),
                _insightItem('⚡', 'Your pattern recognition improved by 32% over last session'),
                _insightItem('📊', 'Try isolating 1-2 bottles per move for cleaner feedback'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassCard(
            child: Column(
              children: [
                const Text('MOVE EFFICIENCY', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...List.generate(5, (i) => _efficiencyBar(i + 1, [0.4, 0.6, 0.8, 0.5, 0.9][i])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
      ),
      child: child,
    );
  }

  Widget _metric(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _insightItem(String emoji, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFB0B0C0), fontSize: 12))),
          ],
        ),
      );

  Widget _efficiencyBar(int move, double value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Move $move', style: const TextStyle(color: Color(0xFF8B8B9A), fontSize: 11)),
                Text('${(value * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: const Color(0xFF2D2D44),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
}