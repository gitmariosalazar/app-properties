import 'package:app_properties/features/properties/search/domain/services/map_navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MapNavigationServiceImpl implements MapNavigationService {
  @override
  Future<void> navigateTo(double latitude, double longitude) async {
    // Generamos la URL de Google Maps para indicar una ruta hacia el destino.
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    
    // Usar inAppBrowserView abre un navegador superpuesto dentro de la misma app.
    // Esto evita que el sistema operativo mate la aplicación por estar en segundo plano
    // (lo cual causa el error "Lost connection to device").
    final success = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    
    if (!success) {
      throw Exception('No se pudo abrir la aplicación de mapas en tu dispositivo.');
    }
  }
}
