import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/properties/search/domain/usecases/get_connection_with_properties.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/presentation/info/cubit/search_connection_cubit.dart';
import 'package:app_properties/features/properties/search/presentation/info/cubit/search_connection_state.dart';

import '../widgets/search_header.dart';
import '../widgets/search_initial_view.dart';
import '../widgets/search_loading_view.dart';
import '../widgets/search_error_view.dart';
import '../widgets/search_empty_view.dart';
import '../widgets/connection_result_card.dart';

class SearchConnectionPage extends StatefulWidget {
  const SearchConnectionPage({super.key});

  @override
  State<SearchConnectionPage> createState() => _SearchConnectionPageState();
}

class _SearchConnectionPageState extends State<SearchConnectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _activeFilter = 'todos';
  bool _isLoadingDetails = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    context.read<SearchConnectionCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Buscador de Acometidas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: cs.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withValues(alpha: 0.05), cs.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // --- HEADER SEARCH BLOCK ---
                SearchHeader(
                  searchController: _searchController,
                  focusNode: _focusNode,
                  onSearch: _onSearch,
                  activeFilter: _activeFilter,
                  onFilterChanged: (newFilter) {
                    setState(() {
                      _activeFilter = newFilter;
                    });
                  },
                ),

                // --- MAIN LIST AREA ---
                Expanded(
                  child: BlocBuilder<SearchConnectionCubit, SearchConnectionState>(
                    builder: (context, state) {
                      if (state is SearchConnectionInitial) {
                        return const SearchInitialView();
                      }
                      if (state is SearchConnectionLoading) {
                        return const SearchLoadingView();
                      }
                      if (state is SearchConnectionError) {
                        return SearchErrorView(
                          message: state.message,
                          onRetry: _onSearch,
                        );
                      }
                      if (state is SearchConnectionLoaded) {
                        final list = state.connections;
                        if (list.isEmpty) {
                          return SearchEmptyView(
                            searchTerm: _searchController.text,
                          );
                        }
                        return _buildResultsList(context, list);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingDetails)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Card(
                  color: theme.cardColor,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: cs.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando detalles del predio...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<ConnectionEntity> list,
  ) {
    // Apply filters
    debugPrint('active filter: $_activeFilter');
    final filtered = list.where((item) {
      if (_activeFilter == 'activos') {
        return item.connectionStateId == 1;
      }
      if (_activeFilter == 'inactivos') {
        return item.connectionStateId != 1;
      }
      return item.connectionStateId == 1;
    }).toList();

    if (filtered.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Text(
          'Ningún predio coincide con el filtro "$_activeFilter".',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.smallSpacing,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ConnectionResultCard(
          connection: item,
          onTap: () async {
            setState(() {
              _isLoadingDetails = true;
            });
            try {
              final fetchUseCase = di.sl<GetConnectionWithProperties>();
              final fullEntity = await fetchUseCase(
                item.connectionCadastralKey,
              );

              if (context.mounted) {
                setState(() {
                  _isLoadingDetails = false;
                });
                context.push(
                  '/update-form',
                  extra: {'connection': fullEntity, 'mode': 'search'},
                );
              }
            } catch (e) {
              if (context.mounted) {
                setState(() {
                  _isLoadingDetails = false;
                });
                final cs = Theme.of(context).colorScheme;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error al cargar detalles del predio: ${e.toString().replaceAll('Exception: ', '')}',
                    ),
                    backgroundColor: cs.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}

