import 'package:flutter/material.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/entities/contact.dart';

class ConnectionDetailsSheet extends StatelessWidget {
  final ConnectionEntity connection;

  const ConnectionDetailsSheet({
    super.key,
    required this.connection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              // Beautiful Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: cs.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalle de Acometida',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${connection.connectionId}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadgeInModal(
                      connection.connectionStateId ?? 0,
                    ),
                  ],
                ),
              ),

              // Main Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Section 1: Acometida Info
                    _buildSectionTitle(
                      theme,
                      cs,
                      'Información de Acometida',
                      Icons.settings_suggest_rounded,
                    ),
                    _buildDetailCard(theme, cs, [
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.vpn_key_rounded,
                        'Clave Catastral',
                        connection.connectionCadastralKey,
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.rate_review_rounded,
                        'Tarifa / Tipo',
                        connection.connectionRateName,
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.speed_rounded,
                        'Número de Medidor',
                        connection.connectionMeterNumber ?? 'Sin Medidor',
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.assignment_rounded,
                        'Número de Contrato',
                        connection.connectionContractNumber ??
                            'Sin Contrato',
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.calendar_today_rounded,
                        'Fecha Instalación',
                        _formatDate(connection.connectionInstallationDate),
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.grid_view_rounded,
                        'Sector / Cuenta',
                        'Sector ${connection.connectionSector} - Cuenta ${connection.connectionAccount}',
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.cleaning_services_rounded,
                        'Alcantarillado',
                        connection.connectionSewerage == true
                            ? 'Sí tiene'
                            : 'No tiene',
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.chrome_reader_mode_rounded,
                        'Lectura Habilitada',
                        connection.connectionIsReadable == true
                            ? 'Sí'
                            : 'No',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Section 2: Propietario Info
                    _buildSectionTitle(
                      theme,
                      cs,
                      'Datos del Propietario',
                      Icons.person_rounded,
                    ),
                    _buildOwnerInfoSection(theme, cs),

                    const SizedBox(height: 20),

                    // Section 3: Predio Info
                    _buildSectionTitle(
                      theme,
                      cs,
                      'Ubicación y Predio',
                      Icons.location_on_rounded,
                    ),
                    _buildDetailCard(theme, cs, [
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.home_work_rounded,
                        'Dirección Acometida',
                        connection.connectionAddress.isEmpty
                            ? 'Sin dirección'
                            : connection.connectionAddress,
                      ),
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.map_rounded,
                        'Zona / Código',
                        '${connection.zoneName ?? "No asignada"} (${connection.zoneCode ?? "NO_CODE"})',
                      ),
                      if (connection.property != null) ...[
                        _buildDetailItem(
                          theme,
                          cs,
                          Icons.vpn_key_rounded,
                          'Clave Catastral Predio',
                          connection.property!.propertyCadastralKey,
                        ),
                        _buildDetailItem(
                          theme,
                          cs,
                          Icons.landscape_rounded,
                          'Tipo de Predio',
                          connection.property!.propertyTypeName,
                        ),
                        _buildDetailItem(
                          theme,
                          cs,
                          Icons.location_city_rounded,
                          'Dirección Predio',
                          connection.property!.propertyAddress,
                        ),
                        _buildDetailItem(
                          theme,
                          cs,
                          Icons.alt_route_rounded,
                          'Callejón / Vía',
                          connection.property!.propertyAlleyway.isEmpty
                              ? 'Sin especificar'
                              : connection.property!.propertyAlleyway,
                        ),
                      ],
                      _buildDetailItem(
                        theme,
                        cs,
                        Icons.my_location_rounded,
                        'Coordenadas GPS',
                        connection.connectionCoordinates ??
                            'Sin coordenadas GPS',
                      ),
                      if (connection.connectionPrecision != null)
                        _buildDetailItem(
                          theme,
                          cs,
                          Icons.gps_fixed_rounded,
                          'Precisión GPS',
                          '${connection.connectionPrecision!.toStringAsFixed(2)} metros',
                        ),
                    ]),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Button
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadgeInModal(int connectionStateId) {
    final color = connectionStateId == 1
        ? const Color(0xFF10B981)
        : Colors.amber.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        connectionStateId == 1 ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    ThemeData theme,
    ColorScheme cs,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(ThemeData theme, ColorScheme cs, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  indent: 48,
                  thickness: 0.6,
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailItem(
    ThemeData theme,
    ColorScheme cs,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: cs.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoSection(ThemeData theme, ColorScheme cs) {
    if (connection.person == null && connection.company == null) {
      return _buildDetailCard(theme, cs, [
        _buildDetailItem(
          theme,
          cs,
          Icons.person_off_rounded,
          'Propietario',
          'Sin Propietario Registrado',
        ),
      ]);
    }

    if (connection.person != null) {
      final p = connection.person!;
      final fullName = '${p.firstName ?? ""} ${p.lastName ?? ""}'.trim();

      String phonesText = 'Sin teléfono';
      final validPhones = p.phones.whereType<PhoneEntity>();
      if (validPhones.isNotEmpty) {
        phonesText = validPhones.map((ph) => ph.numero).join(', ');
      }

      String emailsText = 'Sin correo electrónico';
      final validEmails = p.emails.whereType<EmailEntity>();
      if (validEmails.isNotEmpty) {
        emailsText = validEmails.map((e) => e.email).join(', ');
      }

      return _buildDetailCard(theme, cs, [
        _buildDetailItem(theme, cs, Icons.person_rounded, 'Nombre Completo', fullName),
        _buildDetailItem(
          theme,
          cs,
          Icons.badge_rounded,
          'Cédula / Identificación',
          p.personId,
        ),
        _buildDetailItem(
          theme,
          cs,
          Icons.phone_android_rounded,
          'Teléfono(s)',
          phonesText,
        ),
        _buildDetailItem(theme, cs, Icons.mail_outline_rounded, 'Correo(s)', emailsText),
        _buildDetailItem(
          theme,
          cs,
          Icons.home_rounded,
          'Dirección Domicilio',
          p.address ?? 'Sin dirección',
        ),
        _buildDetailItem(
          theme,
          cs,
          Icons.cake_rounded,
          'Fecha de Nacimiento',
          p.birthDate ?? 'No registrada',
        ),
      ]);
    } else {
      final c = connection.company!;
      final companyName = c.businessName ?? c.commercialName ?? 'Compañía';

      String phonesText = 'Sin teléfono';
      final validPhones = c.phones.whereType<PhoneEntity>();
      if (validPhones.isNotEmpty) {
        phonesText = validPhones.map((ph) => ph.numero).join(', ');
      }

      String emailsText = 'Sin correo electrónico';
      final validEmails = c.emails.whereType<EmailEntity>();
      if (validEmails.isNotEmpty) {
        emailsText = validEmails.map((e) => e.email).join(', ');
      }

      return _buildDetailCard(theme, cs, [
        _buildDetailItem(theme, cs, Icons.business_rounded, 'Razón Social', companyName),
        _buildDetailItem(theme, cs, Icons.badge_rounded, 'RUC', c.ruc),
        _buildDetailItem(
          theme,
          cs,
          Icons.phone_android_rounded,
          'Teléfono(s)',
          phonesText,
        ),
        _buildDetailItem(theme, cs, Icons.mail_outline_rounded, 'Correo(s)', emailsText),
        _buildDetailItem(
          theme,
          cs,
          Icons.home_rounded,
          'Dirección de Empresa',
          c.address ?? 'Sin dirección',
        ),
      ]);
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'No registrada';
    try {
      final parsed = DateTime.parse(rawDate);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate;
    }
  }
}
