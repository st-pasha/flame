import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(GameWidget(game: LakeGame()));
}


class LakeGame extends BaseGame with HasTappableComponents {
  bool _isRunning = true;

  @override
  Future<void> onLoad() async {
    add(Sky(50, 30));
    // camera.setRelativeOffset(Anchor.center);
    viewport = FixedResolutionViewport(Vector2(50, 30));
    // camera.zoomVector ..multiply(Vector2(1, -1));
    camera.snapTo(Vector2(0, -30));
  }

  void startOrStop() {
    if (_isRunning) {
      pauseEngine();
      _isRunning = false;
    } else {
      resumeEngine();
      _isRunning = true;
    }
  }
}

class Sky extends PositionComponent with Tappable, HasGameRef<LakeGame> {
  Sky(double width, double height)
    : skyRect = Rect.fromLTRB(0, 0, width, height),
      stars = [],
      super(size: Vector2(width, height),
            position: Vector2(0, -height));

  /// How fast the time moves in the game, in game hours per second.
  /// The duration of one in-game day is `24/timeScale` seconds.
  double timeScale = 0.5;
  int nStars = 50;

  final List<Star> stars;

  final Rect skyRect;

  // runtime variables
  double currentTime = 0;
  double starsBrightness = 0;
  late Paint currentPaint;

  @override
  Future<void> onLoad() async {
    final random = Random();
    for (var i = 0; i < nStars; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      final b = (random.nextDouble() * 0.8 + 0.2) * (1 - 0.6 * y/height);
      final s = (random.nextDouble() + 1) * 0.05;
      stars.add(Star(x, y, b, s));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    assert(currentTime < 24);
    var i = 0;
    while (skyPalette[i + 1].hour < currentTime) {
      i += 1;
    }
    final f = (currentTime - skyPalette[i].hour) / (skyPalette[i + 1].hour - skyPalette[i].hour);
    assert(f >= 0 && f < 1);
    final bottomColor = HSLColor.lerp(
        skyPalette[i].bottomColor,
        skyPalette[i + 1].bottomColor,
        f
    )!.toColor();
    final topColor = HSLColor.lerp(
        skyPalette[i].topColor,
        skyPalette[i + 1].topColor,
        f
    )!.toColor();
    currentPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, height),
        [topColor, bottomColor, ],
      );
    starsBrightness = skyPalette[i].starBrightness * (1 - f) + skyPalette[i + 1].starBrightness * f;
    currentTime = (currentTime + dt) % 24.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(skyRect, currentPaint);
    const white = Color(0xFFffffff);
    if (starsBrightness > 0) {
      for (final star in stars) {
        final brightness = star.brightness * starsBrightness;
        canvas.drawCircle(
          star.position,
          star.size,
          Paint()..color = white.withOpacity(brightness),
        );
      }
    }
    TextPaint(
        config: const TextPaintConfig(
            color: Color(0xFFffffff),
          fontSize: 2,
        ),
    ).render(
        canvas,
        'time: ${currentTime.toStringAsFixed(1)}',
        Vector2(0, height),
      anchor: Anchor.bottomLeft,
    );
  }

  @override
  bool onTapDown(TapDownInfo info) {
    gameRef.startOrStop();
    return true;
  }
}

/// The colors of the sky at a particular time of day
class SkyColor {
  SkyColor(int top, int bottom, this.hour, this.starBrightness)
    : bottomColor = HSLColor.fromColor(Color(bottom)),
      topColor = HSLColor.fromColor(Color(top));
  final HSLColor bottomColor;
  final HSLColor topColor;
  final double hour;
  final double starBrightness;
}

final skyPalette = <SkyColor>[
  SkyColor(0xFF000205, 0xFF000205, 0, 1.0),
  SkyColor(0xFF000510, 0xFF202836, 4, 1.0),
  SkyColor(0xFF120031, 0xFF3B0AA8, 5, 0.2),
  SkyColor(0xFF650DA3, 0xFFE2AFFF, 6, 0),
  SkyColor(0xFF5421CD, 0xFFC4AFFF, 7, 0),
  SkyColor(0xFF217FC4, 0xFFAFF6FF, 8, 0),
  SkyColor(0xFF3AAEE5, 0xFF8EF2FF, 12, 0),
  SkyColor(0xFF2C70C4, 0xFF829EE7, 18, 0),
  SkyColor(0xFF10417D, 0xFF3380B1, 20, 0.2),
  SkyColor(0xFF000510, 0xFF202836, 21, 1.0),
  SkyColor(0xFF000205, 0xFF000205, 24, 1.0),
];

class Star {
  Star(double x, double y, this.brightness, this.size)
    : position = Offset(x, y);

  final Offset position;
  final double brightness;  // from 0 to 1
  final double size;
}
