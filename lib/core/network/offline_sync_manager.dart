import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/properties/form/update/data/datasources/company_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/customer_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/observation_connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/property_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/create_observation_request.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_company_request.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_connection_request.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_customer_request.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_property_request.dart';

class SyncTask {
  final String id;
  final String type; // 'connection', 'customer', 'company', 'property', 'observation'
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  SyncTask({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'entityId': entityId,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncTask.fromJson(Map<String, dynamic> json) => SyncTask(
        id: json['id'] as String,
        type: json['type'] as String,
        entityId: json['entityId'] as String,
        payload: json['payload'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class OfflineSyncManager {
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  static const String _queueKey = 'OFFLINE_SYNC_QUEUE';
  bool _isProcessing = false;

  OfflineSyncManager({
    required this.sharedPreferences,
    required this.networkInfo,
  }) {
    _initNetworkListener();
  }

  void _initNetworkListener() {
    networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        debugPrint('📶 Conexión restablecida detectada. Iniciando sincronización de cola offline...');
        processQueue();
      }
    });
  }

  Future<void> enqueueTask({
    required String type,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final task = SyncTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
    );

    final tasks = await getTasks();
    tasks.add(task);
    await _saveTasks(tasks);
    debugPrint('💾 Tarea encolada offline: [${task.type}] para la entidad ${task.entityId}');
    
    // Si hay conexión en este instante, intentamos procesar de una vez
    if (await networkInfo.isConnected) {
      processQueue();
    }
  }

  Future<List<SyncTask>> getTasks() async {
    final jsonString = sharedPreferences.getString(_queueKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((item) => SyncTask.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> completeTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _saveTasks(tasks);
    debugPrint('✅ Tarea de sincronización completada y eliminada: $id');
  }

  Future<void> _saveTasks(List<SyncTask> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await sharedPreferences.setString(_queueKey, jsonEncode(jsonList));
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    final tasks = await getTasks();
    if (tasks.isEmpty) {
      _isProcessing = false;
      return;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      _isProcessing = false;
      return;
    }

    debugPrint('🔄 Sincronizando ${tasks.length} tareas pendientes con el servidor...');

    for (final task in tasks) {
      try {
        await _executeTask(task);
        await completeTask(task.id);
      } catch (e) {
        debugPrint('❌ Error al procesar la tarea ${task.id} (${task.type}): $e');
        // Detener el procesamiento en caso de error de red o servidor temporal para preservar el orden cronológico
        break;
      }
    }

    _isProcessing = false;
  }

  Future<void> _executeTask(SyncTask task) async {
    switch (task.type) {
      case 'connection':
        final remoteDS = di.sl<ConnectionRemoteDataSource>();
        final request = UpdateConnectionRequest.fromJson(task.payload);
        await remoteDS.updateConnection(connectionId: task.entityId, request: request);
        break;
      case 'customer':
        final remoteDS = di.sl<CustomerRemoteDataSource>();
        final request = UpdateCustomerRequest.fromJson(task.payload);
        await remoteDS.updateCustomer(customerId: task.entityId, request: request);
        break;
      case 'company':
        final remoteDS = di.sl<CompanyRemoteDataSource>();
        final request = UpdateCompanyRequest.fromJson(task.payload);
        await remoteDS.updateCompany(companyRuc: task.entityId, request: request);
        break;
      case 'property':
        final remoteDS = di.sl<PropertyRemoteDataSource>();
        final request = UpdatePropertyRequest.fromJson(task.payload);
        await remoteDS.updateProperty(cadastralKey: task.entityId, request: request);
        break;
      case 'observation':
        final remoteDS = di.sl<ObservationConnectionRemoteDataSource>();
        final request = CreateObservationRequest.fromJson(task.payload);
        await remoteDS.addObservationConnection(request: request);
        break;
      default:
        throw Exception('Tipo de tarea desconocido: ${task.type}');
    }
  }
}
