// lib/features/properties/presentation/widgets/connection/gps_section.dart
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/components/button/widget_button.dart';

/// GPS section of the connection form.
/// All colors resolved from [ColorScheme] — adapts to light/dark.
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;

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
                  readOnly: true,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: CustomTextField(
                  controller: widget.longitudeCtrl,
                  label: 'Longitud',
                  icon: Icons.east,
                  validator: numberValidator,
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
                child: ActionButton(
                  label: 'Obtener Todo',
                  icon: Icons.my_location,
                  color: cs.secondary,
                  onPressed: widget.onGetLocation,
                  loading: widget.isGettingLocation,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: ActionButton(
                  label: 'Ver en Mapa',
                  icon: Icons.map,
                  color: cs.primary,
                  onPressed: widget.onOpenMap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
