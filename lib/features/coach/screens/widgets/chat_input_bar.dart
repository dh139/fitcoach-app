import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../../core/constants/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final bool              disabled;
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.disabled = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl       = TextEditingController();
  final _focusNode  = FocusNode();
  final _stt        = SpeechToText();
  bool  _sttReady   = false;
  bool  _listening  = false;
  bool  _hasText    = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _initStt();
  }

  Future<void> _initStt() async {
    final ready = await _stt.initialize(
      onError: (_) => setState(() => _listening = false),
    );
    if (mounted) setState(() => _sttReady = ready);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.disabled) return;
    _ctrl.clear();
    setState(() => _hasText = false);
    widget.onSend(text);
  }

  Future<void> _toggleVoice() async {
    if (!_sttReady) return;

    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      final result = _ctrl.text.trim();
      if (result.isNotEmpty) _send();
    } else {
      setState(() => _listening = true);
      await _stt.listen(
        onResult: (result) {
          if (mounted) {
            _ctrl.text = result.recognizedWords;
            _ctrl.selection = TextSelection.fromPosition(
              TextPosition(offset: _ctrl.text.length),
            );
          }
        },
        listenFor:       const Duration(seconds: 30),
        pauseFor:        const Duration(seconds: 3),
        localeId:        'en_IN',
        cancelOnError:   true,
        partialResults:  true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color:  AppColors.surface1,
        border: Border(top: BorderSide(
          color: AppColors.border1, width: 0.5)),
      ),
      child: Row(children: [
        // Voice button
        if (_sttReady)
          GestureDetector(
            onTap: widget.disabled ? null : _toggleVoice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40, height: 40,
              decoration: BoxDecoration(
                color:        _listening
                    ? AppColors.dangerDim
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _listening
                      ? AppColors.dangerBorder
                      : AppColors.border3,
                  width: 0.5,
                ),
              ),
              child: Icon(
                _listening
                    ? Icons.stop_rounded
                    : Icons.mic_none_rounded,
                color: _listening
                    ? AppColors.danger
                    : AppColors.textTertiary,
                size: 18,
              ),
            ),
          ),
        if (_sttReady) const SizedBox(width: 8),

        // Text field
        Expanded(child: Container(
          constraints: const BoxConstraints(maxHeight: 110),
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.limeBorder
                  : AppColors.border3,
              width: _focusNode.hasFocus ? 1 : 0.5,
            ),
          ),
          child: TextField(
            controller:     _ctrl,
            focusNode:      _focusNode,
            onChanged:      (_) => setState(() {}),
            enabled:        !widget.disabled,
            maxLines:       null,
            keyboardType:   TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onSubmitted:    (_) => _send(),
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _listening
                  ? 'Listening...'
                  : 'Ask your AI coach anything...',
              hintStyle: TextStyle(
                fontFamily: 'Inter', fontSize: 13,
                color: _listening
                    ? AppColors.danger
                    : AppColors.textTertiary,
              ),
              border:         InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
            ),
          ),
        )),
        const SizedBox(width: 8),

        // Send button
        GestureDetector(
          onTap: (_hasText && !widget.disabled) ? _send : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color:        (_hasText && !widget.disabled)
                  ? AppColors.lime
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.send_rounded,
              color: (_hasText && !widget.disabled)
                  ? AppColors.bg
                  : AppColors.surface4,
              size: 18,
            ),
          ),
        ),
      ]),
    );
  }
}