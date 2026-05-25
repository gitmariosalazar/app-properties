import 'package:flutter/material.dart';
import 'package:app_properties/core/di/injection.dart';
import 'package:app_properties/features/properties/search/data/datasources/remote_connection_datasource.dart';
import 'package:app_properties/features/properties/search/data/datasources/remote_connection_with_properties_datasource.dart';
import 'package:app_properties/features/properties/search/data/datasources/local_connection_datasource.dart';
import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class OfflinePreloadScreen extends StatefulWidget {
  const OfflinePreloadScreen({super.key});

  @override
  State<OfflinePreloadScreen> createState() => _OfflinePreloadScreenState();
}

class _OfflinePreloadScreenState extends State<OfflinePreloadScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isDownloading = false;
  double _progress = 0.0;
  String _currentStatus = '';
  List<PreloadItem> _results = [];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _startPreload() async {
    final rawText = _inputController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese al menos una clave catastral o cédula.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Split by comma, newlines, or whitespace
    final keys = rawText
        .split(RegExp(r'[,\n\s]+'))
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    if (keys.isEmpty) return;

    // Check internet first
    final hasInternet = await sl<NetworkInfo>().isConnected;
    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requiere conexión a Internet para descargar y precargar los datos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _results = keys.map((k) => PreloadItem(key: k, status: PreloadStatus.pending)).toList();
      _currentStatus = 'Inicializando descarga...';
    });

    final remoteSearch = sl<RemoteConnectionDataSource>();
    final remoteDetail = sl<RemoteConnectionWithPropertiesDataSource>();
    final localCache = sl<LocalConnectionDataSource>();

    int completed = 0;

    for (int i = 0; i < _results.length; i++) {
      final item = _results[i];
      setState(() {
        item.status = PreloadStatus.processing;
        _currentStatus = 'Procesando [${i + 1}/${keys.length}]: ${item.key}';
      });

      try {
        // Step 1: Remote Search
        final connections = await remoteSearch
            .getConnectionByCadastralKeyOrClientIdOrCardId(item.key);

        if (connections.isEmpty) {
          setState(() {
            item.status = PreloadStatus.failed;
            item.error = 'No se encontró el predio';
          });
        } else {
          // Cache list
          await localCache.cacheConnections(item.key, connections);

          // Step 2: Fetch and Cache details for each connection
          int cachedDetails = 0;
          for (final conn in connections) {
            try {
              final details = await remoteDetail
                  .fetchConnectionWithPropertiesByCadastralKey(conn.connectionCadastralKey);
              
              await localCache.cacheConnectionWithProperties(
                conn.connectionCadastralKey,
                details,
              );
              cachedDetails++;
            } catch (e) {
              debugPrint('Error pre-cargando detalle: $e');
            }
          }

          setState(() {
            if (cachedDetails > 0) {
              item.status = PreloadStatus.success;
              item.info = 'Descargado ($cachedDetails predio/s)';
            } else {
              item.status = PreloadStatus.failed;
              item.error = 'Fallo en detalles';
            }
          });
        }
      } catch (e) {
        setState(() {
          item.status = PreloadStatus.failed;
          item.error = e.toString().replaceAll('Exception: ', '');
        });
      }

      completed++;
      setState(() {
        _progress = completed / keys.length;
      });
    }

    setState(() {
      _isDownloading = false;
      _currentStatus = '¡Descarga offline completada!';
    });

    final totalSuccess = _results.where((r) => r.status == PreloadStatus.success).length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cloud_done_rounded, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Precarga Exitosa'),
          ],
        ),
        content: Text(
          'Se han descargado y precargado $totalSuccess de ${keys.length} predios de manera local.\n\n'
          'Ahora puedes salir a campo y realizar consultas y actualizaciones de estos predios 100% offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Precarga de Datos Offline',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.offline_pin_rounded, color: theme.colorScheme.primary, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preparación de Trabajo de Campo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ingresa las claves catastrales o identificadores de las propiedades que visitarás hoy. Las descargaremos en lote para que trabajes 100% sin señal de internet.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Inputs Card
              if (!_isDownloading) ...[
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Claves Catastrales / Cédulas',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'Pega o escribe las claves aquí...\nEjemplo:\n1704592031\n1720349581001\n0912495821',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _startPreload,
                            icon: const Icon(Icons.cloud_download_rounded),
                            label: const Text('Descargar para Uso Offline'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Loading Process Card
                Expanded(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Descargando Datos del Servidor...',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: _progress,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                            backgroundColor: theme.colorScheme.outlineVariant,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progress * 100).toInt()}% Completado',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _currentStatus,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Detalle del Lote:',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final item = _results[index];
                                IconData icon = Icons.pending_outlined;
                                Color color = Colors.grey;

                                if (item.status == PreloadStatus.processing) {
                                  icon = Icons.sync;
                                  color = theme.colorScheme.primary;
                                } else if (item.status == PreloadStatus.success) {
                                  icon = Icons.check_circle_rounded;
                                  color = Colors.green;
                                } else if (item.status == PreloadStatus.failed) {
                                  icon = Icons.cancel_rounded;
                                  color = Colors.red;
                                }

                                return ListTile(
                                  leading: Icon(icon, color: color),
                                  title: Text(
                                    item.key,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    item.status == PreloadStatus.success
                                        ? (item.info ?? '')
                                        : (item.status == PreloadStatus.failed
                                            ? (item.error ?? 'Error')
                                            : 'Pendiente'),
                                    style: TextStyle(
                                      color: item.status == PreloadStatus.failed
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: item.status == PreloadStatus.processing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum PreloadStatus { pending, processing, success, failed }

class PreloadItem {
  final String key;
  PreloadStatus status;
  String? info;
  String? error;

  PreloadItem({
    required this.key,
    required this.status,
    this.info,
    this.error,
  });
}
