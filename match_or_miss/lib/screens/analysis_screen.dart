// lib/screens/analysis_screen.dart
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/ai_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => AnalysisScreenState();
}

class AnalysisScreenState extends State<AnalysisScreen> {
  final AIService _aiService = AIService();
  AIPlayerAnalysis? _analysis;
  bool _isLoading = false;
  
  // Sample data for demonstration
  final List<Attempt> _sampleAttempts = [];
  
  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }
  
  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
    });
    
    // Load actual game data from storage
    await Future.delayed(const Duration(seconds: 1));
    _analysis = await _aiService.analyzePlayerBehavior(_sampleAttempts);
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Performance Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analysis == null
              ? _buildEmptyState()
              : _buildAnalysisContent(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 80, color: Colors.white54),
          const SizedBox(height: 20),
          const Text(
            'No Game Data Yet',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Play some games to see your analysis',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('PLAY NOW'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(),
          const SizedBox(height: 20),
          _buildSuggestionsCard(),
          const SizedBox(height: 20),
          _buildMoveEfficiencyCard(),
          const SizedBox(height: 20),
          _buildImprovementTips(),
        ],
      ),
    );
  }
  
  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.purple.shade900],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'PERFORMANCE STATS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Avg Changes',
                _analysis!.avgVariablesChanged.toStringAsFixed(1),
                Icons.change_circle,
              ),
              _buildStatItem(
                'Impulsive',
                _analysis!.impulsiveMoves.toString(),
                Icons.speed,
              ),
              _buildStatItem(
                'Progress Rate',
                _analysis!.progressRate.toStringAsFixed(2),
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildStatItem(
            'Repeated Mistakes',
            _analysis!.repeatedMistakes.toString(),
            Icons.repeat,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon,
      {bool fullWidth = false}) {
    Widget item = Column(
      children: [
        Icon(icon, color: Colors.cyan, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
    
    if (fullWidth) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.cyan),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return item;
  }
  
  Widget _buildSuggestionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow),
              SizedBox(width: 10),
              Text(
                'AI SUGGESTIONS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._analysis!.suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.cyan)),
                  Expanded(
                    child: Text(
                      suggestion.substring(2), // Remove bullet point
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildMoveEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOVE EFFICIENCY ANALYSIS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _analysis!.moveEfficiencies.length,
              itemBuilder: (context, index) {
                final move = _analysis!.moveEfficiencies[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${move.moveNumber}'),
                  ),
                  title: Text(
                    move.feedback,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    move.efficiency > 0
                        ? Icons.arrow_upward
                        : move.efficiency < 0
                            ? Icons.arrow_downward
                            : Icons.remove,
                    color: move.efficiency > 0
                        ? Colors.green
                        : move.efficiency < 0
                            ? Colors.red
                            : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImprovementTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.teal.shade900],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 IMPROVEMENT STRATEGIES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '• Start with all same color to identify matches',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          const Text(
            '• Change only 1-2 positions per move',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          const Text(
            '• Keep successful matches in place',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          const Text(
            '• Use binary search logic for faster solving',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.memory, color: Colors.cyan),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Training your working memory improves puzzle-solving speed by up to 40%',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}