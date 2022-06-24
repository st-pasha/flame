import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:meta/meta.dart';

class RectangleComponent extends PolygonComponent {
  RectangleComponent({
    super.position,
    super.size,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
  }) : super(sizeToVertices(size ?? Vector2.zero(), anchor));

  RectangleComponent.square({
    Vector2? position,
    double? size,
    double? angle,
    Anchor? anchor,
    int? priority,
    Paint? paint,
  }) : this(
          position: position,
          size: Vector2.all(size ?? 0),
          angle: angle,
          anchor: anchor,
          priority: priority,
          paint: paint,
        );

  /// With this constructor you define the [RectangleComponent] in relation to
  /// the `parentSize`. For example having [relation] as of (0.8, 0.5) would
  /// create a rectangle that fills 80% of the width and 50% of the height of
  /// `parentSize`.
  RectangleComponent.relative(
    Vector2 relation, {
    required super.parentSize,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
    super.paint,
    super.shrinkToBounds,
  }) : super.relative([
          relation.clone(),
          Vector2(relation.x, -relation.y),
          -relation,
          Vector2(-relation.x, relation.y),
        ]);

  /// This factory will create a [RectangleComponent] from a positioned [Rect].
  factory RectangleComponent.fromRect(
    Rect rect, {
    double? angle,
    Anchor anchor = Anchor.topLeft,
    int? priority,
    Paint? paint,
  }) {
    return RectangleComponent(
      position: anchor == Anchor.topLeft
          ? rect.topLeft.toVector2()
          : Anchor.topLeft.toOtherAnchorPosition(
              rect.topLeft.toVector2(),
              anchor,
              rect.size.toVector2(),
            ),
      size: rect.size.toVector2(),
      angle: angle,
      anchor: anchor,
      priority: priority,
      paint: paint,
    );
  }

  @protected
  static List<Vector2> sizeToVertices(
    Vector2 size,
    Anchor? componentAnchor,
  ) {
    final anchor = componentAnchor ?? Anchor.topLeft;
    return [
      Vector2(-size.x * anchor.x, -size.y * anchor.y),
      Vector2(-size.x * anchor.x, size.y - size.y * anchor.y),
      Vector2(size.x - size.x * anchor.x, size.y - size.y * anchor.y),
      Vector2(size.x - size.x * anchor.x, -size.y * anchor.y),
    ];
  }
}
