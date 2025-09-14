import 'package:flutter/material.dart';
import '../screens/network_logs_screen.dart';
import '../services/network_logs_service.dart';
import 'network_logs_bubble_overlay.dart';

class NetworkLogsBubble extends StatefulWidget {
  const NetworkLogsBubble({super.key});

  @override
  State<NetworkLogsBubble> createState() => _NetworkLogsBubbleState();
}

class _NetworkLogsBubbleState extends State<NetworkLogsBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  int _logCount = 0;
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to log count changes
    NetworkLogsService.instance.logsStream.listen((logs) {
      if (mounted) {
        setState(() {
          _logCount = logs.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Future<void> _onTap() async {
    setState(() {
      _visible = false;
    });

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NetworkLogsScreen()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    }
  }

  void _onLongPress() {
    // Show dialog to remove the bubble
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Network Logs Bubble'),
        content: const Text('Do you want to hide the network logs bubble?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Remove the overlay
              NetworkLogsBubbleOverlay.removeActiveOverlay();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: _onTap,
              onLongPress: _onLongPress,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.network_check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (_logCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _logCount > 99 ? '99+' : _logCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
