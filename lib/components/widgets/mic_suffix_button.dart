import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/core/services/speech_service.dart';
import 'package:flutter/material.dart';

class MicSuffixButton extends StatefulWidget {
  final TextEditingController controller;
  
  const MicSuffixButton({
    super.key,
    required this.controller,
  });

  @override
  State<MicSuffixButton> createState() => _MicSuffixButtonState();
}

class _MicSuffixButtonState extends State<MicSuffixButton> {
  final _speechService = di.sl<SpeechService>();
  bool _isListening = false;
  String _initialText = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPressStart: (_) async {
        _initialText = widget.controller.text;
        if (_initialText.isNotEmpty && !_initialText.endsWith(' ')) {
          _initialText += ' ';
        }
        setState(() {
          _isListening = true;
        });

        await _speechService.startListening((recognizedText) {
          if (mounted) {
            widget.controller.text = _initialText + recognizedText;
            // Mover el cursor al final
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length),
            );
          }
        });
      },
      onLongPressEnd: (_) async {
        setState(() {
          _isListening = false;
        });
        await _speechService.stopListening();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isListening
              ? colors.error.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening ? colors.error : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
