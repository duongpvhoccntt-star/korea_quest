import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smooth_wheel_scroll/flutter_smooth_wheel_scroll.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';

const _viewportHeight = 300.0;

Widget _scrollView({bool disableAnimations = false, double height = 1200}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(800, _viewportHeight),
        disableAnimations: disableAnimations,
      ),
      child: Scaffold(
        body: SizedBox(
          height: _viewportHeight,
          child: AppScrollView(
            child: SizedBox(
              height: height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

AppScrollController _controller(WidgetTester tester) {
  final scrollView = tester.widget<SingleChildScrollView>(
    find.byType(SingleChildScrollView),
  );
  return scrollView.controller! as AppScrollController;
}

Future<void> _wheel(
  WidgetTester tester,
  double dy, {
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) async {
  tester.binding.handlePointerEvent(
    PointerScrollEvent(
      kind: kind,
      position: tester.getCenter(find.byType(Scrollable)),
      scrollDelta: Offset(0, dy),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('uses a 220 ms non-bouncing spring for mouse-wheel input', (
    tester,
  ) async {
    await tester.pumpWidget(_scrollView());
    final controller = _controller(tester);
    final motion = controller.motion as SpringWheelMotion;

    expect(motion.duration, const Duration(milliseconds: 220));
    expect(motion.bounce, 0);

    await _wheel(tester, 60);
    expect(controller.offset, 0);

    await tester.pump(const Duration(milliseconds: 110));
    expect(controller.offset, greaterThan(0));
    expect(controller.offset, lessThan(60));

    await tester.pumpAndSettle();
    expect(controller.offset, closeTo(60, 0.01));
  });

  testWidgets('accumulates repeated wheel input and clamps to the extents', (
    tester,
  ) async {
    await tester.pumpWidget(_scrollView(height: 400));
    final controller = _controller(tester);

    await _wheel(tester, 60);
    await tester.pump(const Duration(milliseconds: 20));
    await _wheel(tester, 60);
    await tester.pump(const Duration(milliseconds: 20));
    await _wheel(tester, 60);
    await tester.pumpAndSettle();

    expect(controller.position.maxScrollExtent, 100);
    expect(controller.offset, 100);

    await _wheel(tester, -300);
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });

  testWidgets('keeps trackpad input native and immediate', (tester) async {
    await tester.pumpWidget(_scrollView());
    final controller = _controller(tester);

    await _wheel(tester, 60, kind: PointerDeviceKind.trackpad);

    expect(controller.offset, 60);
    await tester.pumpAndSettle();
    expect(controller.offset, 60);
  });

  testWidgets('disables wheel animation for reduced-motion users', (
    tester,
  ) async {
    await tester.pumpWidget(_scrollView(disableAnimations: true));
    final controller = _controller(tester);
    final motion = controller.motion as SpringWheelMotion;

    expect(motion.duration, Duration.zero);
    await _wheel(tester, 60);
    expect(controller.offset, 60);
  });
}
