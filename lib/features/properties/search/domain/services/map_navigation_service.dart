abstract class MapNavigationService {
  /// Abre una aplicación de mapas (como Google Maps) para navegar
  /// hacia las coordenadas indicadas (latitud y longitud).
  Future<void> navigateTo(double latitude, double longitude);
}
