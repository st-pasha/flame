/// [LineMetrics] represents dimensions of a single line of text, or a fragment
/// of a line.
///
/// A line of text can be thought of as surrounded by a box (rect) that outlines
/// the boundaries of the text, plus there is a [baseline] inside the box which
/// is the line on top of which the text is placed.
///
/// The [LineMetrics] box surrounding a piece of text is not necessarily tight:
/// there's usually some amount of space above and below to improve legibility
/// of multi-line text.
class LineMetrics {
  LineMetrics({
    required double left,
    required double baseline,
    double width = 0,
    double ascent = 0,
    double descent = 0,
  })  : _left = left,
        _baseline = baseline,
        _width = width,
        _ascent = ascent,
        _descent = descent;

  /// X-coordinate of the left edge of the box.
  double get left => _left;
  double _left;

  /// Y-coordinate of the baseline of the box. When several line fragments are
  /// placed next to each other, their baselines will match.
  double get baseline => _baseline;
  double _baseline;

  /// The total width of the box.
  double get width => _width;
  double _width;

  /// The distance from the baseline to the top of the box.
  double get ascent => _ascent;
  double _ascent;

  /// The distance from the baseline to the bottom of the box.
  double get descent => _descent;
  double _descent;

  double get right => left + width;
  double get top => baseline - ascent;
  double get bottom => baseline + descent;
  double get height => ascent + descent;

  /// Moves the [LineMetrics] box by the specified offset [dx], [dy] leaving its
  /// width and height unmodified.
  void translate(double dx, double dy) {
    _left += dx;
    _baseline += dy;
  }

  /// Sets the position of the left edge of this [LineMetrics] box, leaving the
  /// [right] edge in place.
  void setLeftEdge(double x) {
    _width = _left + _width - x;
    _left = x;
  }

  /// Appends another [LineMetrics] box that is adjacent to the current and on
  /// the same baseline. The current object will be modified to encompass the
  /// [other] box.
  void append(LineMetrics other) {
    assert(right == other.left);
    assert(baseline == other.baseline);
    _width += other.width;
    if (_ascent < other.ascent) {
      _ascent = other.ascent;
    }
    if (_descent < other.descent) {
      _descent = other.descent;
    }
  }

  @override
  String toString() => 'LineMetrics(left: $left, baseline: $baseline, '
      'width: $width, ascent: $ascent, descent: $descent)';
}
