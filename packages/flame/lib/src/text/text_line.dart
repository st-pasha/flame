import 'package:flame/src/text/inline/text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:meta/meta.dart';

/// A single line within an [TextElement].
@internal
abstract class TextLine {
  LineMetrics get metrics;
}
