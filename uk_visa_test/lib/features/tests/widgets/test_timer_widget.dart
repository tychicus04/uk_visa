import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestTimerWidget extends StatefulWidget {
  final Duration totalDuration;
  final VoidCallback? onTimeUp;
  final Function(Duration remaining)? onTimeUpdate;

  const TestTimerWidget({
    super.key,
    required this.totalDuration,
    this.onTimeUp,
    this.onTimeUpdate,
  });

  @override
  State<TestTimerWidget> createState() => _TestTimerWidgetState();
}

class _TestTimerWidgetState extends State<TestTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalDuration;

    _controller = AnimationController(
      duration: widget.totalDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    _startTimer();
  }

  void _startTimer() {
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining = _remaining - const Duration(seconds: 1);
      });

      widget.onTimeUpdate?.call(_remaining);

      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        widget.onTimeUp?.call();
      }
    });
  }

  Color _getTimerColor() {
    final progress = _remaining.inSeconds / widget.totalDuration.inSeconds;
    if (progress > 0.5) return Colors.green;
    if (progress > 0.25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getTimerColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getTimerColor().withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                  backgroundColor: _getTimerColor().withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.access_time,
                size: 16,
                color: _getTimerColor(),
              ),
              const SizedBox(width: 4),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _getTimerColor(),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}