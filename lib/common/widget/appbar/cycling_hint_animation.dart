import 'dart:async';

import 'package:flutter/material.dart';

class CyclingHint extends StatefulWidget {
  final Color color;
  final double fontSize;

  const CyclingHint({required this.color, required this.fontSize});

  @override
  State<CyclingHint> createState() => CyclingHintState();
}

class CyclingHintState extends State<CyclingHint> {
  static const _words = ['streetwear', 'shirts', 'joggers', 'formal wear'];

  int _wordIndex = 0;
  String _displayText = '';
  bool _isDeleting = false;
  bool _cursorVisible = true;
  Timer? _typeTimer;
  Timer? _cursorTimer;

  static const _typeSpeed = Duration(milliseconds: 80);
  static const _deleteSpeed = Duration(milliseconds: 45);
  static const _pauseAfterWord = Duration(milliseconds: 1400);
  static const _pauseBeforeType = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _tick();
    // Blink cursor independently
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _cursorVisible = !_cursorVisible);
    });
  }

  void _tick() {
    final word = _words[_wordIndex];

    if (!_isDeleting) {
      if (_displayText.length < word.length) {
        _typeTimer = Timer(_typeSpeed, () {
          if (!mounted) return;
          setState(
              () => _displayText = word.substring(0, _displayText.length + 1));
          _tick();
        });
      } else {
        // Finished typing — pause then delete
        _typeTimer = Timer(_pauseAfterWord, () {
          if (!mounted) return;
          _isDeleting = true;
          _tick();
        });
      }
    } else {
      if (_displayText.isNotEmpty) {
        _typeTimer = Timer(_deleteSpeed, () {
          if (!mounted) return;
          setState(() => _displayText =
              _displayText.substring(0, _displayText.length - 1));
          _tick();
        });
      } else {
        // Done deleting — next word
        _isDeleting = false;
        _wordIndex = (_wordIndex + 1) % _words.length;
        _typeTimer = Timer(_pauseBeforeType, () {
          if (!mounted) return;
          _tick();
        });
      }
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: widget.color,
      fontSize: widget.fontSize,
      fontFamily: "InstrumentSans",
      fontWeight: FontWeight.w500,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Search for ', style: style),
        Flexible(
          child: Text(
            '$_displayText${_cursorVisible ? '|' : ' '}',
            style: style,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
