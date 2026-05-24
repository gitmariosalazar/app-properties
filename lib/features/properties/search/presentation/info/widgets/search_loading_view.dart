import 'package:flutter/material.dart';

class SearchLoadingView extends StatelessWidget {
  const SearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            strokeWidth: 3.5,
          ),
          const SizedBox(height: 16),
          Text(
            'Buscando predios en la API...',
            style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary),
          ),
        ],
      ),
    );
  }
}
