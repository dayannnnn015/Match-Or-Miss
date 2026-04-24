import 'package:flutter/material.dart';

import '../models/game_models.dart';

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
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    if (attempts.isEmpty) {
      return const Text('No attempts yet');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: attempts.length,
      itemBuilder: (context, index) {
        final attempt = attempts[attempts.length - 1 - index];
        return ListTile(
          title: Text('Attempt #${attempt.attemptNumber}'),
          subtitle: Text('Matches: ${attempt.matches}'),
        );
      },
    );
  }
}
