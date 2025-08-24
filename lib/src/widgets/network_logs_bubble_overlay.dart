import 'package:flutter/material.dart';
import 'network_logs_bubble.dart';

/// Overlay for [NetworkLogsBubble].
class NetworkLogsBubbleOverlay extends StatefulWidget {
  static const double _defaultPadding = 30;

  // Track if an overlay is already active
  static OverlayEntry? _activeOverlay;

  const NetworkLogsBubbleOverlay._({
    this.right = 0,
    this.bottom = 0,
    this.draggable = false,
  });

  final double bottom;
  final double right;
  final bool draggable;

  /// Attach overlay to specified [context]. The bubble will be draggable unless
  /// [draggable] set to `false`. Initial distance from the bubble to the screen
  /// edge can be configured using [bottom] and [right] parameters.
  /// Returns null if an overlay is already active.
  static OverlayEntry? attachTo(
    BuildContext context, {
    bool rootOverlay = true,
    double bottom = _defaultPadding,
    double right = _defaultPadding,
    bool draggable = true,
  }) {
    // Check if an overlay is already active
    if (_activeOverlay != null) {
      return null; // Don't create a new overlay
    }

    // create overlay entry
    final entry = OverlayEntry(
      builder: (context) => NetworkLogsBubbleOverlay._(
        bottom: bottom,
        right: right,
        draggable: draggable,
      ),
    );

    // Store the active overlay reference
    _activeOverlay = entry;

    // insert on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final overlay = Overlay.of(context, rootOverlay: rootOverlay);
        overlay.insert(entry);
      } catch (e) {
        _activeOverlay = null; // Reset on error
      }
    });

    // return
    return entry;
  }

  /// Remove the active overlay if it exists
  static void removeActiveOverlay() {
    if (_activeOverlay != null) {
      _activeOverlay!.remove();
      _activeOverlay = null;
    }
  }

  /// Force create a new overlay, removing any existing one first
  static OverlayEntry? forceAttachTo(
    BuildContext context, {
    bool rootOverlay = true,
    double bottom = _defaultPadding,
    double right = _defaultPadding,
    bool draggable = true,
  }) {
    // Always remove any existing overlay first
    removeActiveOverlay();

    // Create a new overlay
    return attachTo(
      context,
      rootOverlay: rootOverlay,
      bottom: bottom,
      right: right,
      draggable: draggable,
    );
  }

  @override
  State<NetworkLogsBubbleOverlay> createState() =>
      _NetworkLogsBubbleOverlayState();
}

class _NetworkLogsBubbleOverlayState extends State<NetworkLogsBubbleOverlay> {
  Offset? position;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);
    final screenWidth = screen.size.width;
    final screenHeight = screen.size.height;

    if (widget.draggable) {
      return Positioned(
        left: position == null
            ? screenWidth - widget.right - screen.padding.right - 40
            : position!.dx,
        top: position == null
            ? screenHeight - widget.bottom - screen.padding.bottom - 40
            : position!.dy,
        child: Draggable(
          feedback: const NetworkLogsBubble(),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            setState(() {
              position = details.offset;
            });
          },
          child: const NetworkLogsBubble(),
        ),
      );
    }
    return Positioned(
      right: widget.right + screen.padding.right,
      bottom: widget.bottom + screen.padding.bottom,
      child: const NetworkLogsBubble(),
    );
  }
}
