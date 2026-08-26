import 'package:app_properties/components/loaders/professional_loader.dart';
import 'package:flutter/material.dart';

class SearchLoadingView extends StatelessWidget {
  const SearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProfessionalLoader(
            label: 'Buscando predios...',
            description: 'Por favor espere...',
          ),
        ],
      ),
    );
  }
}
