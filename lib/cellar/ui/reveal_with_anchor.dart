import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Keeps the widget of [anchorKey] in view the first time [child] asks to be
/// scrolled into view (wine-culture-languages, owner decision on the form
/// filled from a text).
///
/// The name field of the add form takes the focus on open (u4-cellar
/// BR1.18) and its text field then scrolls its caret into view. With long
/// texts at 200% the scroll stopped with the autofill bar above it cut by the
/// top edge, and its buttons shorter than 48 dp (A2). Here the first such
/// request reveals the area from the top of the anchor (the autofill bar) to
/// the caret: when it fits, both stay visible; when it does not, the bar is
/// aligned with the top edge. When the field is already visible nothing
/// scrolls, so the form is unchanged wherever it already fitted.
///
/// Later requests (typing, the keyboard opening, focus coming back) are
/// passed on unchanged, so the caret always stays visible while typing.
class RevealWithAnchor extends SingleChildRenderObjectWidget {
  const RevealWithAnchor({
    super.key,
    required this.anchorKey,
    required super.child,
  });

  /// The widget kept in view together with [child] on the first reveal; no
  /// widget mounted with this key means an ordinary reveal.
  final GlobalKey anchorKey;

  @override
  RenderRevealWithAnchor createRenderObject(BuildContext context) =>
      RenderRevealWithAnchor(anchorKey);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRevealWithAnchor renderObject,
  ) {
    renderObject.anchorKey = anchorKey;
  }
}

/// The render object of [RevealWithAnchor].
class RenderRevealWithAnchor extends RenderProxyBox {
  RenderRevealWithAnchor(this.anchorKey);

  GlobalKey anchorKey;

  /// True once the first request to be shown went through.
  bool get firstRevealDone => _firstRevealDone;
  bool _firstRevealDone = false;

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final isFirst = !_firstRevealDone;
    _firstRevealDone = true;
    final anchorTop = isFirst ? _anchorTop() : null;
    if (anchorTop == null || !hasSize) {
      super.showOnScreen(
        descendant: descendant,
        rect: rect,
        duration: duration,
        curve: curve,
      );
      return;
    }
    final target = descendant ?? this;
    final targetRect = rect ?? target.paintBounds;
    final inThis = MatrixUtils.transformRect(
      target.getTransformTo(this),
      targetRect,
    );
    super.showOnScreen(
      descendant: this,
      rect: Rect.fromLTRB(
        inThis.left,
        anchorTop < inThis.top ? anchorTop : inThis.top,
        inThis.right,
        inThis.bottom,
      ),
      duration: duration,
      curve: curve,
    );
  }

  /// The top of the anchor in the coordinates of this box, or `null` when
  /// the anchor is not laid out in the same tree.
  double? _anchorTop() {
    final anchor = anchorKey.currentContext?.findRenderObject();
    if (anchor is! RenderBox || !anchor.attached || !anchor.hasSize) {
      return null;
    }
    if (!attached || !hasSize) return null;
    return globalToLocal(anchor.localToGlobal(Offset.zero)).dy;
  }
}
