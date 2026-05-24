import 'package:flutter/material.dart';

class SearchEmptyView extends StatelessWidget {
  final String searchTerm;

  const SearchEmptyView({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 72,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin resultados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No encontramos ninguna acometida o predio que coincida con "$searchTerm". Revisa el término e intenta nuevamente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
