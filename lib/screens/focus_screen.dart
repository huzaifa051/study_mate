import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class FocusScreen extends StatefulWidget {
  final String taskTitle;

  const FocusScreen({super.key, required this.taskTitle});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const int _focusSeconds = 25 * 60;
  static const int _breakSeconds = 5 * 60;
  static const int _totalSessions = 4;

  Timer? _timer;
  int _remaining = _focusSeconds;
  bool _isRunning = false;
  bool _isBreak = false;
  int _session = 1;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _totalForPhase => _isBreak ? _breakSeconds : _focusSeconds;

  double get _progress => 1 - (_remaining / _totalForPhase);

  String get _timeText {
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remaining > 0) {
          setState(() => _remaining--);
        } else {
          _finishPhase(showMessage: true);
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = _totalForPhase;
    });
  }

  void _finishPhase({required bool showMessage}) {
    _timer?.cancel();

    String message;
    setState(() {
      _isRunning = false;
      if (!_isBreak) {
        _isBreak = true;
        _remaining = _breakSeconds;
        message = _session == _totalSessions
            ? 'All sessions done. Great work!'
            : 'Session $_session complete. Time for a break.';
      } else {
        _isBreak = false;
        _remaining = _focusSeconds;
        _session = _session < _totalSessions ? _session + 1 : 1;
        message = 'Break over. Ready for session $_session?';
      }
    });

    if (showMessage && mounted) {
      final text = _isBreak
          ? (_session == _totalSessions
                ? 'Session $_session complete. Take a break.'
                : 'Session $_session complete. Take a break.')
          : 'Break over. Ready for session $_session?';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.charcoal,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.stone,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Text(
                _isBreak ? 'TAKE A SHORT BREAK' : 'NOW FOCUSING ON',
                style: const TextStyle(
                  color: AppColors.sage,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _isBreak ? 'Rest and recharge' : widget.taskTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.serif(22, color: AppColors.stone),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFF33403A),
                        color: _isBreak ? AppColors.clay : AppColors.sage,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _timeText,
                          style: AppTheme.serif(54, color: AppColors.stone),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Session $_session of $_totalSessions',
                          style: TextStyle(color: AppColors.sage),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalSessions, (index) {
                  final done = index < _session - 1;
                  final current = index == _session - 1;
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? AppColors.sage
                          : current
                          ? AppColors.stone
                          : Colors.transparent,
                      border: Border.all(
                        color: done || current
                            ? Colors.transparent
                            : const Color(0xFF4D5A53),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleButton(
                    icon: Icons.refresh,
                    size: 52,
                    onTap: _resetTimer,
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.stone,
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        size: 38,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _CircleButton(
                    icon: Icons.skip_next,
                    size: 52,
                    onTap: () => _finishPhase(showMessage: false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF4D5A53)),
        ),
        child: Icon(icon, color: AppColors.stone, size: 24),
      ),
    );
  }
}
