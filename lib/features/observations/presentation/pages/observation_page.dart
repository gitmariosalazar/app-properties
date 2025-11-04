import 'package:flutter/material.dart';
import 'package:app_properties/utils/date_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/observations/domain/entities/observation_entity.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ObservationPage extends StatelessWidget {
  final String? connectionId;

  const ObservationPage({super.key, required this.connectionId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(
              "Observaciones",
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black38,
      ),
      body: BlocBuilder<ObservationBloc, ObservationState>(
        builder: (context, state) {
          if (state is ObservationLoading) {
            debugPrint(
              'Cargando observaciones...${connectionId ?? 'sin connectionId'}',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (state is ObservationError) {
            return _buildError(context, state.message);
          } else if (state is FindAllObservationLoaded) {
            final observations = state.observation;
            if (observations.isEmpty) {
              return _buildEmpty(context);
            }
            return AnimatedList(
              key: const ValueKey('observation_list'),
              initialItemCount: observations.length,
              padding: EdgeInsets.all(context.mediumSpacing),
              itemBuilder: (context, index, animation) {
                final obs = observations[index];
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
                    child: _buildObservationCard(context, obs),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: _buildActionButton(
                context,
                label: "Cargar observaciones",
                icon: Icons.refresh,
                onPressed: () {
                  context.read<ObservationBloc>().add(
                    FindAllObservationsEvent(),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: AlwaysStoppedAnimation(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              color: Colors.grey[500],
              size: context.iconLarge * 1.2,
            ),
            context.vSpace(0.02),
            Text(
              "No hay observaciones disponibles",
              style: context.bodyLarge.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: context.bodyLarge.fontSize! * 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            context.vSpace(0.025),
            _buildActionButton(
              context,
              label: "Reintentar",
              icon: Icons.refresh,
              onPressed: () {
                context.read<ObservationBloc>().add(FindAllObservationsEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: FadeTransition(
        opacity: AlwaysStoppedAnimation(1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: context.iconLarge * 1.2,
            ),
            context.vSpace(0.02),
            Text(
              "❌ Error: $message",
              style: context.bodyLarge.copyWith(
                color: Colors.red[800],
                fontWeight: FontWeight.w700,
                fontSize: context.bodyLarge.fontSize! * 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            context.vSpace(0.025),
            _buildActionButton(
              context,
              label: "Reintentar",
              icon: Icons.refresh,
              onPressed: () {
                context.read<ObservationBloc>().add(FindAllObservationsEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: context.iconMedium),
      label: Text(
        label,
        style: context.buttonText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(
          horizontal: context.largeSpacing * 1.2,
          vertical: context.mediumSpacing * 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.mediumBorderRadiusValue),
        ),
        elevation: 4,
        shadowColor: Colors.black38,
      ),
    );
  }

  Widget _buildObservationCard(BuildContext context, ObservationEntity obs) {
    final type = obs.noveltyTypeName.toUpperCase();
    final color = _getColorForNovelty(type);
    final icon = _getIconForNovelty(type);
    final connectionIdText = obs.connectionId.isNotEmpty
        ? obs.connectionId
        : 'Sin ID de conexión';

    return Padding(
      padding: EdgeInsets.only(bottom: context.mediumSpacing),
      child: Material(
        elevation: context.cardElevation + 2,
        borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
          onTap: () => _showDetailsDialog(context, obs, color, icon),
          child: Padding(
            padding: EdgeInsets.all(context.mediumSpacing * 1.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título ocupando todo el ancho
                Row(
                  children: [
                    Text(
                      obs.observationTitle,
                      style: context.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: context.titleExtraSmall.fontSize!,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.smallSpacing * 0.5,
                          horizontal: context.mediumSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(
                            context.smallBorderRadiusValue,
                          ),
                        ),
                        child: Text(
                          'C.C: $connectionIdText',
                          style: context.bodySmall.copyWith(
                            color: Colors.blueGrey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: context.bodySmall.fontSize! * 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                context.vSpace(0.01),
                // Contenido principal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: context.iconMedium,
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(
                        icon,
                        color: color,
                        size: context.iconMedium * 0.85,
                      ),
                    ),
                    SizedBox(width: context.mediumSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obs.observationDetail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyMedium.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          context.vSpace(0.01),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.smallSpacing * 0.6,
                                  horizontal: context.mediumSpacing,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(
                                    context.smallBorderRadiusValue,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey[700],
                                      size: context.iconExtraSmall,
                                    ),
                                    context.hSpace(0.005),
                                    Text(
                                      formatDateTime(
                                        DateTime.parse(obs.registrationDate),
                                      ),
                                      style: context.bodySmall.copyWith(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.smallSpacing * 0.6,
                                  horizontal: context.mediumSpacing,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    context.smallBorderRadiusValue,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: context.bodySmall.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: color,
                        size: context.iconSmall,
                      ),
                      tooltip: "Ver detalles",
                      onPressed: () =>
                          _showDetailsDialog(context, obs, color, icon),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    ObservationEntity obs,
    Color color,
    IconData icon,
  ) {
    final connectionIdText = obs.connectionId.isNotEmpty
        ? obs.connectionId
        : 'Sin ID de conexión';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.mediumSpacing,
          vertical: context.largeSpacing,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.05)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.mediumSpacing * 1.2),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título ocupando todo el ancho
                  Row(
                    children: [
                      CircleAvatar(
                        radius: context.iconMedium,
                        backgroundColor: color.withOpacity(0.2),
                        child: Icon(
                          icon,
                          color: color,
                          size: context.iconMedium * 0.85,
                        ),
                      ),
                      SizedBox(width: context.mediumSpacing),
                      Expanded(
                        child: Text(
                          obs.observationTitle,
                          style: context.titleMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: context.titleExtraSmall.fontSize!,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  context.vSpace(0.01),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.smallSpacing * 0.5,
                        horizontal: context.mediumSpacing,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(
                          context.smallBorderRadiusValue,
                        ),
                      ),
                      child: Text(
                        'C.C: $connectionIdText',
                        style: context.bodySmall.copyWith(
                          color: Colors.blueGrey[800],
                          fontWeight: FontWeight.w600,
                          fontSize: context.bodySmall.fontSize! * 1.1,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: context.mediumSpacing * 2,
                    thickness: 1.2,
                    color: Colors.grey[200],
                  ),
                  _infoRow(context, "📝 Detalle", obs.observationDetail),
                  _infoRow(
                    context,
                    "📅 Fecha",
                    formatDateTime(DateTime.parse(obs.registrationDate)),
                  ),
                  _infoRow(context, "📍 Dirección", obs.address),
                  _infoRow(
                    context,
                    "👤 Cliente",
                    "${obs.clientName} (${obs.clientId})",
                  ),
                  _infoRow(
                    context,
                    "🔢 Lectura anterior",
                    obs.previousReading.toString(),
                  ),
                  _infoRow(
                    context,
                    "🔢 Lectura actual",
                    obs.currentReading.toString(),
                  ),
                  _infoRow(context, "⚙️ Tipo de novedad", obs.noveltyTypeName),
                  _infoRow(
                    context,
                    "📋 Descripción de novedad",
                    obs.noveltyTypeDescription,
                  ),
                  if (obs.actionRecommended != null)
                    _infoRow(
                      context,
                      "🛠️ Acción recomendada",
                      obs.actionRecommended,
                    ),
                  context.vSpace(0.025),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: color,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.mediumSpacing * 1.5,
                          vertical: context.mediumSpacing,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.mediumBorderRadiusValue,
                          ),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text(
                        "Cerrar",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.mediumSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontSize: context.bodyMedium.fontSize! * 0.95,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForNovelty(String type) {
    switch (type.toUpperCase()) {
      case 'NORMAL':
        return Colors.green[600]!;
      case 'CONSUMO BAJO':
        return Colors.amber[500]!;
      case 'CONSUMO ALTO':
        return Colors.amber[700]!;
      case 'CONSUMO MUY BAJO':
        return Colors.red[600]!;
      case 'CONSUMO EXCESIVO':
        return Colors.red[800]!;
      case 'LECTURA INVÁLIDA':
        return Colors.purple[600]!;
      case 'SIN LECTURA':
        return Colors.grey[600]!;
      default:
        return Colors.grey[500]!;
    }
  }

  IconData _getIconForNovelty(String type) {
    switch (type.toUpperCase()) {
      case 'NORMAL':
        return Icons.check_circle;
      case 'CONSUMO BAJO':
        return Icons.trending_down;
      case 'CONSUMO ALTO':
        return Icons.trending_up;
      case 'CONSUMO MUY BAJO':
        return Icons.arrow_downward;
      case 'CONSUMO EXCESIVO':
        return Icons.arrow_upward;
      case 'LECTURA INVÁLIDA':
        return Icons.error;
      case 'SIN LECTURA':
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}
