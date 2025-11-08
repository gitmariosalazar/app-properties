// lib/features/properties/presentation/widgets/connection/gps_section.dart
import 'package:app_properties/components/button/responsive_button.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/utils/validators.dart';
import 'package:flutter/material.dart';

class GpsSection extends StatefulWidget {
  final TextEditingController latitudeCtrl;
  final TextEditingController longitudeCtrl;
  final TextEditingController accuracyCtrl;
  final TextEditingController countryCtrl;
  final TextEditingController provinceCtrl;
  final TextEditingController cantonCtrl;
  final TextEditingController addressFullCtrl;
  final TextEditingController precisionCtrl;
  final TextEditingController geolocationDateCtrl;
  final VoidCallback onGetLocation;
  final VoidCallback onOpenMap;
  final bool isGettingLocation;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const GpsSection({
    super.key,
    required this.latitudeCtrl,
    required this.longitudeCtrl,
    required this.accuracyCtrl,
    required this.countryCtrl,
    required this.provinceCtrl,
    required this.cantonCtrl,
    required this.addressFullCtrl,
    required this.precisionCtrl,
    required this.geolocationDateCtrl,
    required this.onGetLocation,
    required this.onOpenMap,
    required this.isGettingLocation,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  State<GpsSection> createState() => _GpsSectionState();
}

class _GpsSectionState extends State<GpsSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // MANTIENE EL ESTADO

  @override
  void initState() {
    super.initState();
    // Opcional: Puedes forzar una actualización si ya hay datos
    // Pero el padre ya llama a _reverseGeocode
  }

  @override
  Widget build(BuildContext context) {
    // OBLIGATORIO para AutomaticKeepAliveClientMixin
    super.build(context);

    return FormCard(
      title: 'Ubicación GPS',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.latitudeCtrl,
                  label: 'Latitud',
                  icon: Icons.north,
                  validator: numberValidator,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: CustomTextField(
                  controller: widget.longitudeCtrl,
                  label: 'Longitud',
                  icon: Icons.east,
                  validator: numberValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.accuracyCtrl,
                  label: 'Precisión (m)',
                  icon: Icons.gps_fixed,
                  readOnly: true,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: CustomTextField(
                  controller: widget.countryCtrl,
                  label: 'País',
                  icon: Icons.flag,
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.provinceCtrl,
                  label: 'Provincia',
                  icon: Icons.map,
                  readOnly: true,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: CustomTextField(
                  controller: widget.cantonCtrl,
                  label: 'Cantón',
                  icon: Icons.location_city,
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: widget.addressFullCtrl,
            label: 'Dirección Completa',
            icon: Icons.home,
            readOnly: true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ResponsiveButton(
                  label: 'Obtener Todo',
                  icon: Icons.my_location,
                  color: AppColors.secondary,
                  height: context.mediumSpacing * 5,
                  animationController: widget.animationController,
                  scaleAnimation: widget.scaleAnimation,
                  onPressed: widget.onGetLocation,
                  loading: widget.isGettingLocation,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: ResponsiveButton(
                  label: 'Ver en Mapa',
                  icon: Icons.map,
                  color: AppColors.primary,
                  onPressed: widget.onOpenMap,
                  height: context.mediumSpacing * 5,
                  animationController: widget.animationController,
                  scaleAnimation: widget.scaleAnimation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
