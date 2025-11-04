import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:go_router/go_router.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const accent = Color(0xFFFFC107);
  static const background = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const surface = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const warning = Color(0xFFFF9800);
}

class ViewDataScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ViewDataScreen({super.key, required this.data});

  @override
  State<ViewDataScreen> createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientName = _safeString(widget.data['clientName']) ?? 'Sin nombre';
    final connectionId = _safeString(widget.data['connectionId']) ?? 'N/A';
    final isNaturalPerson =
        (_safeString(widget.data['clientType']) ?? 'natural').toLowerCase() ==
        'natural';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, connectionId),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: context.screenPadding,
          child: Column(
            children: [
              _buildHeroSummaryCard(context, connectionId, clientName),
              context.vSpace(0.03),
              _buildClientTypeCard(context, isNaturalPerson),
              context.vSpace(0.03),

              // Cliente Natural o Empresa
              if (isNaturalPerson)
                ..._buildNaturalPersonSection(context)
              else
                ..._buildCompanySection(context),

              context.vSpace(0.03),
              _buildConnectionSection(context),
              context.vSpace(0.03),
              _buildPropertySection(context),
              context.vSpace(0.04),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String id) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 22),
        onPressed: () => {context.pop()},
        tooltip: 'Regresar',
      ),
      title: Text(
        'Detalle $id',
        style: context.titleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.copy, size: 22),
          onPressed: () => _copyToClipboard(id, 'ID copiado'),
          tooltip: 'Copiar ID',
        ),
      ],
    );
  }

  Widget _buildHeroSummaryCard(BuildContext context, String id, String name) {
    final address =
        _safeString(widget.data['connectionAddress']) ?? 'Sin dirección';

    return Container(
      padding: context.cardPadding * 1.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: context.isTablet ? 38 : 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.water_drop,
              size: context.isTablet ? 40 : 34,
              color: Colors.white,
            ),
          ),
          context.hSpace(0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: context.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.vSpace(0.005),
                Text(
                  name,
                  style: context.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                context.vSpace(0.005),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.white70),
                    context.hSpace(0.01),
                    Expanded(
                      child: Text(
                        address,
                        style: context.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTypeCard(BuildContext context, bool isNatural) {
    return _buildInfoCard(
      context: context,
      title: 'Tipo de Cliente',
      icon: isNatural ? Icons.person : Icons.business,
      color: isNatural ? AppColors.secondary : AppColors.accent,
      child: Text(
        isNatural ? 'Persona Natural' : 'Empresa',
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isNatural ? AppColors.secondary : AppColors.accent,
        ),
      ),
    );
  }

  List<Widget> _buildNaturalPersonSection(BuildContext context) {
    final nameParts = _getNameParts();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    return [
      _buildInfoCard(
        context: context,
        title: 'Datos Personales',
        icon: Icons.person_outline,
        child: Column(
          children: [
            _infoRow(context, 'Nombres', firstName, icon: Icons.badge),
            _infoRow(context, 'Apellidos', lastName, icon: Icons.person),
            _infoRow(
              context,
              'Cédula',
              _safeString(widget.data['clientId']),
              icon: Icons.credit_card,
            ),
            _infoRow(
              context,
              'F. Nacimiento',
              _safeString(widget.data['clientDob']),
              icon: Icons.cake,
            ),
            _infoRow(
              context,
              'Dirección',
              _safeString(widget.data['clientAddress']),
              icon: Icons.home,
            ),
          ],
        ),
      ),
      context.vSpace(0.02),
      _buildListCard(
        context,
        'Correos Electrónicos',
        _getList('clientEmails'),
        Icons.email,
      ),
      context.vSpace(0.02),
      _buildListCard(
        context,
        'Teléfonos',
        _getList('clientPhones'),
        Icons.phone,
      ),
    ];
  }

  List<Widget> _buildCompanySection(BuildContext context) {
    return [
      _buildInfoCard(
        context: context,
        title: 'Datos de la Empresa',
        icon: Icons.business,
        child: Column(
          children: [
            _infoRow(
              context,
              'Razón Social',
              _safeString(widget.data['companySocialReason']),
              icon: Icons.domain,
            ),
            _infoRow(
              context,
              'Nombre Comercial',
              _safeString(widget.data['companyName']),
              icon: Icons.store,
            ),
            _infoRow(
              context,
              'RUC',
              _safeString(widget.data['companyRuc']),
              icon: Icons.credit_card,
            ),
            _infoRow(
              context,
              'Dirección',
              _safeString(widget.data['companyAddress']),
              icon: Icons.location_on,
            ),
          ],
        ),
      ),
      context.vSpace(0.02),
      _buildListCard(
        context,
        'Correos',
        _getList('companyEmails'),
        Icons.email,
      ),
      context.vSpace(0.02),
      _buildListCard(
        context,
        'Teléfonos',
        _getList('companyPhones'),
        Icons.phone,
      ),
    ];
  }

  Widget _buildConnectionSection(BuildContext context) {
    final lat = _getCoordinate('latitude', 'connectionCoordinates', true);
    final lng = _getCoordinate('longitude', 'connectionCoordinates', false);

    return Column(
      children: [
        _buildInfoCard(
          context: context,
          title: 'Datos de la Acometida',
          icon: Icons.water_drop,
          child: Column(
            children: [
              _infoRow(
                context,
                'Medidor',
                _safeString(widget.data['connectionMeterNumber']),
                icon: Icons.confirmation_number,
              ),
              _infoRow(
                context,
                'Contrato',
                _safeString(widget.data['connectionContractNumber']),
                icon: Icons.description,
              ),
              _infoRow(
                context,
                'Dirección',
                _safeString(widget.data['connectionAddress']),
                icon: Icons.location_on,
              ),
              _infoRow(
                context,
                'Instalación',
                _safeString(widget.data['connectionInstallationDate']),
                icon: Icons.calendar_today,
              ),
              _infoRow(
                context,
                'Personas',
                _safeString(widget.data['connectionPeopleNumber']) ?? '4',
                icon: Icons.group,
              ),
              _infoRow(
                context,
                'Referencia',
                _safeString(widget.data['connectionReference']),
                icon: Icons.pin_drop,
              ),
              _infoRow(
                context,
                'Sector',
                _safeString(widget.data['connectionSector']),
                icon: Icons.location_city,
              ),
              _infoRow(
                context,
                'Cuenta',
                _safeString(widget.data['connectionAccount']),
                icon: Icons.account_box,
              ),
              _infoRow(
                context,
                'Zona',
                _safeString(widget.data['connectionZone']),
                icon: Icons.map,
              ),
              _infoRow(
                context,
                'Tarifa',
                _safeString(widget.data['connectionRateName']) ?? 'COMERCIAL',
                icon: Icons.category,
              ),
              _infoRow(
                context,
                'Alcantarillado',
                _boolToString(widget.data['connectionSewerage'], true),
                icon: Icons.plumbing,
              ),
              _infoRow(
                context,
                'Estado',
                _boolToString(widget.data['connectionStatus'], true),
                icon: Icons.check_circle,
              ),
            ],
          ),
        ),
        context.vSpace(0.02),
        _buildGpsCard(context, lat, lng),
      ],
    );
  }

  Widget _buildGpsCard(BuildContext context, String lat, String lng) {
    final hasCoords = lat != 'N/A' && lng != 'N/A';
    final coords = hasCoords ? '$lat, $lng' : 'No disponible';

    return _buildInfoCard(
      context: context,
      title: 'Ubicación GPS',
      icon: Icons.location_searching,
      color: hasCoords ? AppColors.secondary : AppColors.warning,
      child: Column(
        children: [
          _infoRow(context, 'Latitud', lat),
          _infoRow(context, 'Longitud', lng),
          context.vSpace(0.02),
          Row(
            children: [
              Icon(Icons.map, size: 18, color: AppColors.primary),
              context.hSpace(0.01),
              Expanded(
                child: Text(
                  coords,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          context.vSpace(0.02),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  label: 'Copiar',
                  icon: Icons.copy,
                  onPressed: hasCoords
                      ? () => _copyToClipboard(coords, 'Coordenadas copiadas')
                      : null,
                ),
              ),
              context.hSpace(0.01),
              Expanded(
                child: _ActionChip(
                  label: 'Abrir Mapa',
                  icon: Icons.open_in_new,
                  color: AppColors.secondary,
                  onPressed: hasCoords ? () => _openMap(lat, lng) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySection(BuildContext context) {
    return _buildInfoCard(
      context: context,
      title: 'Datos del Predio',
      icon: Icons.home_work,
      child: Column(
        children: [
          _infoRow(
            context,
            'Clave Catastral',
            _safeString(widget.data['connectionCadastralKey']),
            icon: Icons.key,
          ),
          _infoRow(
            context,
            'Dirección',
            _safeString(widget.data['propertyAddress']) ??
                _safeString(widget.data['connectionAddress']),
            icon: Icons.home,
          ),
          _infoRow(
            context,
            'Callejón',
            _safeString(widget.data['propertyAlleyway']) ?? 'Calle Principal',
            icon: Icons.streetview,
          ),
          context.vSpace(0.015),
          _infoRow(
            context,
            'Área Terreno',
            '${_safeString(widget.data['propertyLandArea']) ?? '0'} m²',
            icon: Icons.landscape,
          ),
          _infoRow(
            context,
            'Área Construcción',
            '${_safeString(widget.data['propertyConstructionArea']) ?? '0'} m²',
            icon: Icons.home_repair_service,
          ),
          context.vSpace(0.015),
          _infoRow(
            context,
            'Valor Terreno',
            '\$${_safeString(widget.data['propertyLandValue']) ?? '0'}',
            icon: Icons.attach_money,
          ),
          _infoRow(
            context,
            'Valor Construcción',
            '\$${_safeString(widget.data['propertyConstructionValue']) ?? '0'}',
            icon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => {context.go('/manually-entry')},
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.keyboard),
      label: const Text('Nuevo Busqueda'),
      tooltip: 'Ingresar otra acometida',
    );
  }

  // === WIDGETS REUTILIZABLES ===
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    Color? color,
    required Widget child,
  }) {
    return Card(
      elevation: context.cardElevation * 1.2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              (color ?? AppColors.primary).withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: context.cardPadding * 1.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color ?? AppColors.primary,
                  size: context.iconMedium,
                ),
                context.hSpace(0.015),
                Text(
                  title,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color ?? AppColors.primary,
                  ),
                ),
              ],
            ),
            context.vSpace(0.02),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String? value, {
    IconData? icon,
  }) {
    final displayValue = value?.isNotEmpty == true ? value : '—';
    return Padding(
      padding: EdgeInsets.only(bottom: context.smallSpacing * 0.9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            context.hSpace(0.01),
          ],
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: context.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue!,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: displayValue == '—'
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
  ) {
    final displayItems = items.isEmpty ? ['No registrado'] : items;
    final isEmpty = items.isEmpty;

    return _buildInfoCard(
      context: context,
      title: title,
      icon: icon,
      color: isEmpty ? AppColors.warning : null,
      child: Column(
        children: displayItems.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.extraSmallSpacing * 1.2),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: context.iconSmall,
                  color: isEmpty
                      ? AppColors.warning
                      : AppColors.primary.withOpacity(0.7),
                ),
                context.hSpace(0.01),
                Expanded(
                  child: Text(
                    item,
                    style: context.bodyMedium.copyWith(
                      color: isEmpty
                          ? AppColors.textSecondary.withOpacity(0.6)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ActionChip({
    required String label,
    required IconData icon,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }

  // === HELPERS ===
  String? _safeString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  List<String> _getNameParts() {
    final name = _safeString(widget.data['clientName']) ?? '';
    return name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  }

  List<String> _getList(String key) {
    final value = widget.data[key];
    if (value is List)
      return value
          .map((e) => _safeString(e) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return [];
  }

  String _getCoordinate(String key, String fallbackKey, bool isLat) {
    final val = _safeString(widget.data[key]);
    if (val != null) return val;

    final coords = _safeString(widget.data[fallbackKey]);
    if (coords == null) return 'N/A';

    final parts = coords.split(',').map((s) => s.trim()).toList();
    if (parts.length != 2) return 'N/A';

    return isLat ? parts[0] : parts[1];
  }

  String _boolToString(dynamic value, bool defaultValue) {
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is String) return value.toLowerCase() == 'true' ? 'Sí' : 'No';
    return defaultValue ? 'Sí' : 'No';
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.secondary),
    );
  }

  Future<void> _openMap(String lat, String lng) async {
    final url = 'https://www.google.com/maps?q=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _copyToClipboard(
        '$lat, $lng',
        'Coordenadas copiadas (mapa no disponible)',
      );
    }
  }
}
