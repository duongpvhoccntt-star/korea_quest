import 'package:flutter/material.dart';
import 'package:flutter_smooth_wheel_scroll/flutter_smooth_wheel_scroll.dart';

const _appWheelScrollDuration = Duration(milliseconds: 220);

/// The shared controller for vertical mouse-wheel scrolling in KoreaQuest.
///
/// Mouse-wheel input follows a short, non-bouncing spring. Trackpads, touch,
/// keyboard input, scrollbars, and programmatic scrolling keep Flutter's
/// native behavior.
class AppScrollController extends SmoothScrollController {
  AppScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  }) : super(motion: _motion(reduceMotion: false));

  void setReduceMotion(bool reduceMotion) {
    motion = _motion(reduceMotion: reduceMotion);
  }

  static WheelMotion _motion({required bool reduceMotion}) =>
      WheelMotion.spring(
        duration: reduceMotion ? Duration.zero : _appWheelScrollDuration,
        bounce: 0,
      );
}

/// A vertical [SingleChildScrollView] with the app's mouse-wheel motion.
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = _controller;
    if (controller is AppScrollController) {
      controller.setReduceMotion(MediaQuery.disableAnimationsOf(context));
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
    if (controller is AppScrollController) {
      controller.setReduceMotion(MediaQuery.disableAnimationsOf(context));
    }
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
