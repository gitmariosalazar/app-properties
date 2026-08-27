import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class SpeechService {
  Future<bool> initialize();
  Future<void> startListening(Function(String) onResult);
  Future<void> stopListening();
  bool get isListening;
}

class SpeechServiceImpl implements SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Solicitar permiso de micrófono
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Error en SpeechToText: $error'),
      onStatus: (status) => print('Estado de SpeechToText: $status'),
    );

    return _isInitialized;
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_speechToText.isListening) {
      await stopListening();
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: 'es_ES', // Se puede parametrizar o detectar el idioma local
      cancelOnError: true,
      partialResults: true,
      listenMode: ListenMode.dictation,
    );
  }

  @override
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  @override
  bool get isListening => _speechToText.isListening;
}
