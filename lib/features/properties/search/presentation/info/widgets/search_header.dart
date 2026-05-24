import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/features/properties/search/presentation/info/cubit/search_connection_cubit.dart';
import 'connection_filter_chip.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final VoidCallback onSearch;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const SearchHeader({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.onSearch,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(context.mediumSpacing),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar and Search button horizontally in a Row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    onSubmitted: (_) => onSearch(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Clave catastral o Cédula/RUC',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: theme.hintColor,
                            ),
                            onPressed: () {
                              searchController.clear();
                              context.read<SearchConnectionCubit>().search('');
                            },
                          );
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search Button
              ElevatedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                label: const Text(
                  'Buscar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ConnectionFilterChip(
                  label: 'Todos',
                  icon: const Icon(Icons.list_rounded),
                  isSelected: activeFilter == 'todos',
                  onTap: () => onFilterChanged('todos'),
                ),
                const SizedBox(width: 8),
                ConnectionFilterChip(
                  label: 'Activos',
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  isSelected: activeFilter == 'activos',
                  onTap: () => onFilterChanged('activos'),
                ),
                const SizedBox(width: 8),
                ConnectionFilterChip(
                  label: 'Inactivos',
                  icon: const Icon(Icons.cancel_outlined),
                  isSelected: activeFilter == 'inactivos',
                  onTap: () => onFilterChanged('inactivos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
