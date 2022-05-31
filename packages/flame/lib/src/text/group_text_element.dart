import 'dart:math';
import 'dart:ui' hide LineMetrics;

import 'package:flame/src/text/inline_text_element.dart';
import 'package:flame/src/text/line_metrics.dart';
import 'package:flame/src/text/text_line.dart';

/// An [InlineTextElement] containing other [InlineTextElement]s inside.
///
/// This class allows forming a tree of [InlineTextElement]s, placing different
/// kinds of [InlineTextElement]s next to each other.
class GroupTextElement extends InlineTextElement {
  GroupTextElement(this._children);

  final List<InlineTextElement> _children;
  final List<TextLine> _lines = [];
  int _currentIndex = 0;

  @override
  bool get isLaidOut => _currentIndex == _children.length;

  @override
  LayoutResult layOutNextLine(LineMetrics bounds) {
    assert(!isLaidOut);
    final metric = LineMetrics(left: bounds.left, baseline: bounds.baseline);
    final line = _InlineTextGroupLine(metric);
    while (!isLaidOut) {
      final child = _children[_currentIndex];
      final result = child.layOutNextLine(bounds);
      switch (result) {
        case LayoutResult.didNotAdvance:
          if (metric.left == metric.right) {
            return LayoutResult.didNotAdvance;
          } else {
            _lines.add(line);
            return LayoutResult.unfinished;
          }

        case LayoutResult.unfinished:
          _lines.add(line);
          return LayoutResult.unfinished;

        case LayoutResult.done:
          final lastLine = child.lastLine;
          final lastMetric = lastLine.metrics;
          line.addChild(lastLine);
          metric.right = lastMetric.right;
          metric.top = min(metric.top, lastMetric.top);
          metric.bottom = max(metric.bottom, lastMetric.bottom);
          bounds.left = metric.right;
          _currentIndex++;
          break;
      }
    }
    _lines.add(line);
    return LayoutResult.done;
  }

  @override
  Iterable<TextLine> get lines => _lines;

  @override
  TextLine get lastLine => _lines.last;

  @override
  void render(Canvas canvas) {
    assert(isLaidOut);
    _children.forEach((e) => e.render(canvas));
  }

  @override
  void resetLayout() {
    _currentIndex = 0;
    _lines.clear();
    _children.forEach((e) => e.resetLayout());
  }
}

class _InlineTextGroupLine implements TextLine {
  _InlineTextGroupLine(this.metrics);

  @override
  final LineMetrics metrics;

  final List<TextLine> _children = [];

  void addChild(TextLine line) => _children.add(line);
}