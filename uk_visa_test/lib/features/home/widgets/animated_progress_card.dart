import 'package:flutter/material.dart';

class AnimatedProgressCard extends StatefulWidget {
  final String title;
  final int percentage;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const AnimatedProgressCard({
    super.key,
    required this.title,
    required this.percentage,
    required this.subtitle,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  State<AnimatedProgressCard> createState() => _AnimatedProgressCardState();
}

class _AnimatedProgressCardState extends State<AnimatedProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: _progressAnimation.value,
                                strokeWidth: 8,
                                backgroundColor: widget.color.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: TweenAnimationBuilder<int>(
                                  duration: Duration(milliseconds: 1500),
                                  tween: IntTween(begin: 0, end: widget.percentage),
                                  builder: (context, value, child) {
                                    return Text(
                                      '$value%',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: widget.color,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}