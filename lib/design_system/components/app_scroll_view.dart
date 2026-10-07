import 'package:flutter/material.dart';

/// The shared native scroll controller for KoreaQuest.
///
/// Keeping Flutter's native controller ensures mouse wheels, trackpads, touch,
/// keyboard input, and scrollbars follow the platform's supported behavior.
class AppScrollController extends ScrollController {
  AppScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });
}

/// A vertical [SingleChildScrollView] with an explicitly owned controller.
///
/// When no [controller] is supplied, this widget owns and disposes an
/// [AppScrollController]. An external controller remains owned by its caller.
class AppScrollView extends StatefulWidget {
  const AppScrollView({
    required this.child,
    super.key,
    this.controller,
    this.padding,
    this.physics,
    this.reverse = false,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
  });

  final Widget child;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final String? restorationId;

  @override
  State<AppScrollView> createState() => _AppScrollViewState();
}

class _AppScrollViewState extends State<AppScrollView> {
  AppScrollController? _ownedController;

  ScrollController get _controller =>
      widget.controller ?? (_ownedController ??= AppScrollController());

  @override
  void didUpdateWidget(covariant AppScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    } else if (oldWidget.controller != null && widget.controller == null) {
      _ownedController = AppScrollController();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return SingleChildScrollView(
      controller: controller,
      padding: widget.padding,
      physics: widget.physics,
      reverse: widget.reverse,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      child: widget.child,
    );
  }
}
