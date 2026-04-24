import 'package:flutter/material.dart';

import '../models/ai_models.dart';

class AiFeedback extends StatelessWidget {
  const AiFeedback({
    super.key,
    required this.hint,
  });

  final AiHint hint;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('AI Hint'),
        subtitle: Text(hint.message),
        trailing: Text('${(hint.confidence * 100).toStringAsFixed(0)}%'),
      ),
    );
  }
}
