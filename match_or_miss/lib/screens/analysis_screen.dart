import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/ai_service.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/glassmorphic_widgets.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => AnalysisScreenState();
}

class AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  AIPlayerAnalysis? _analysis;
  bool _isLoading = false;
  final List<Attempt> _sampleAttempts = [];

  late final AnimationController _introController;
  late final Animation<double> _introFade;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _introFade = CurvedAnimation(parent: _introController, curve: Curves.easeOut);
    _loadAnalysis();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    _analysis = await _aiService.analyzePlayerBehavior(_sampleAttempts);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF09111F), Color(0xFF10283D), Color(0xFF183948)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _introFade,
            child: Column(
              children: [
                _header(context),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: GlowingProgressIndicator(
                            value: 0.7,
                            color: Color(0xFF6DD3FF),
                            label: 'AI',
                          ),
                        )
                      : _analysis == null
                          ? _buildEmptyState(context)
                          : _buildAnalysisContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'PERFORMANCE ANALYSIS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            onPressed: _loadAnalysis,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6DD3FF)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassmorphicCard(
          borderRadius: 18,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_outlined, size: 62, color: Color(0xFF6DD3FF)),
              const SizedBox(height: 14),
              const Text(
                'No Game Data Yet',
                style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Play a few rounds and your AI coach will generate personalized feedback.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: 'Play Now',
                gradient: const LinearGradient(colors: [Color(0xFF6DD3FF), Color(0xFF2A80C9)]),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreHero(),
          const SizedBox(height: 14),
          _buildSuggestionsCard(),
          const SizedBox(height: 14),
          _buildMoveEfficiencyCard(),
          const SizedBox(height: 14),
          _buildImprovementTips(),
        ],
      ),
    );
  }

  Widget _buildScoreHero() {
    return GlassmorphicCard(
      borderRadius: 18,
      border: Border.all(color: const Color(0xFF6DD3FF).withValues(alpha: 0.35)),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Performance Snapshot',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  icon: Icons.tune,
                  label: 'Avg Changes',
                  value: _analysis!.avgVariablesChanged.toStringAsFixed(1),
                  color: const Color(0xFF6DD3FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  icon: Icons.bolt,
                  label: 'Impulsive',
                  value: _analysis!.impulsiveMoves.toString(),
                  color: const Color(0xFFFFA15E),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  icon: Icons.show_chart,
                  label: 'Progress',
                  value: _analysis!.progressRate.toStringAsFixed(2),
                  color: const Color(0xFF56D676),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.repeat_rounded, color: Color(0xFFFFC37A)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Repeated Mistakes', style: TextStyle(color: Colors.white70)),
                ),
                Text(
                  _analysis!.repeatedMistakes.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    final suggestions = _analysis!.suggestions;
    return GlassmorphicCard(
      borderRadius: 18,
      border: Border.all(color: const Color(0xFF56D676).withValues(alpha: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFC37A)),
              SizedBox(width: 8),
              Text('AI Suggestions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 10),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, size: 7, color: Color(0xFF6DD3FF)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.replaceFirst(RegExp(r'^\s*[•\-*]\s*'), ''),
                      style: const TextStyle(color: Colors.white70, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveEfficiencyCard() {
    return GlassmorphicCard(
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move Efficiency',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._analysis!.moveEfficiencies.take(6).map((move) {
            final color = move.efficiency > 0
                ? const Color(0xFF56D676)
                : move.efficiency < 0
                    ? const Color(0xFFFF7A7A)
                    : const Color(0xFF9AA9B8);
            final icon = move.efficiency > 0
                ? Icons.trending_up_rounded
                : move.efficiency < 0
                    ? Icons.trending_down_rounded
                    : Icons.drag_handle_rounded;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text('${move.moveNumber}', style: TextStyle(color: color, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(move.feedback, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ),
                  Icon(icon, color: color, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImprovementTips() {
    return GlassmorphicCard(
      borderRadius: 18,
      border: Border.all(color: const Color(0xFFFFA15E).withValues(alpha: 0.25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Improvement Blueprint',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          SizedBox(height: 10),
          Text('1. Keep confirmed positions untouched as anchors.', style: TextStyle(color: Colors.white70, height: 1.4)),
          SizedBox(height: 4),
          Text('2. Change only one or two slots per move for cleaner feedback.', style: TextStyle(color: Colors.white70, height: 1.4)),
          SizedBox(height: 4),
          Text('3. Use timed mode to train pattern recall under pressure.', style: TextStyle(color: Colors.white70, height: 1.4)),
          SizedBox(height: 4),
          Text('4. Review your last three failed moves before retrying.', style: TextStyle(color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }
}
