import 'package:flutter/material.dart';
import 'package:app_properties/shared/files/presentation/use_file_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_properties/shared/files/domain/repositories/file_repository.dart';

class PhotoGallery extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final String? title;

  const PhotoGallery({super.key, required this.imagePaths, this.title});

  @override
  ConsumerState<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends ConsumerState<PhotoGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return _buildEmptyState();
    }

    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),

        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: PageController(initialPage: _currentIndex),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              final path = widget.imagePaths[index];
              final cleanPath = path.startsWith('/') ? path.substring(1) : path;

              return GestureDetector(
                onTap: () => _showFullScreen(context, index),
                child: _PhotoItem(
                  key: ValueKey(cleanPath), // ← Clave única
                  path: cleanPath,
                ),
              );
            },
          ),
        ),

        // Indicadores
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imagePaths.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: _currentIndex == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? cs.primary
                      : cs.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 96,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay fotos disponibles',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoGallery(
          imagePaths: widget.imagePaths,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ==================== WIDGET POR FOTO ====================
class _PhotoItem extends ConsumerWidget {
  final String path;

  const _PhotoItem({super.key, required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewState = ref.watch(useFilePreviewFamilyProvider(path));

    if (previewState.bytes == null && !previewState.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(useFilePreviewFamilyProvider(path).notifier)
            .load(FileCategory.incidents, path);
      });
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: previewState.bytes != null
          ? Image.memory(
              previewState.bytes!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildErrorWidget(),
            )
          : _buildLoadingWidget(),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
      ),
    );
  }
}

// ==================== FULL SCREEN ====================
class FullScreenPhotoGallery extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenPhotoGallery({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<FullScreenPhotoGallery> createState() =>
      _FullScreenPhotoGalleryState();
}

class _FullScreenPhotoGalleryState
    extends ConsumerState<FullScreenPhotoGallery> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text('${_currentIndex + 1} / ${widget.imagePaths.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          final path = widget.imagePaths[index];
          final cleanPath = path.startsWith('/') ? path.substring(1) : path;
          return _PhotoItem(path: cleanPath);
        },
      ),
    );
  }
}
