import 'dart:ui' hide LineMetrics;

import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame/src/text/common/text_line.dart';

/// [TextElement] is the base class describing a span of text that has "inline"
/// placement rules.
///
/// Concrete implementations of this class must know how to lay themselves out
/// (i.e. determine the exact placement and size of each internal piece), and
/// then render on a canvas after the layout.
///
/// The layout mechanism used by this class works as follows:
/// - initially, the [lines] iterator is empty;
/// - the owner of the text will call [layOutNextLine], requesting the text to
///   be placed within the specified `bounds`: onto the `baseline` and between
///   coordinates `left` and `right`;
/// - if the text can be fit between the requested coordinates, then
///   [LayoutResult.done] is returned, and the text is considered "laid out";
/// - if the text can only fit partially between `x0` and `x1`, then the method
///   will return [LayoutResult.unfinished], and place the line just produced
///   into the [lines] iterable. At this moment the caller should call
///   [layOutNextLine] again, to continue the layout process;
/// - if the text cannot fit between `x0` and `x1` at all, even partially, then
///   [LayoutResult.didNotAdvance] is returned. The caller needs to either
///   supply more horizontal distance next time, or apply other mitigation
///   strategies;
/// - at any point the caller can call [lines] in order to obtain access to the
///   lines that were already laid out.
///
/// An inline text can potentially span multiple lines, be adjacent to other
/// [TextElement]s, or contain other [TextElement]s inside.
abstract class TextElement {
  /// Performs layout of a single line of text.
  ///
  /// The [bounds] parameter specifies where the text should be placed: on y-
  /// axis the text should be placed at `bounds.baseline`; horizontally, it
  /// should start at `bounds.left` and do not go beyond `bounds.right`. The
  /// implementation should attempt to put as much text as possible within these
  /// constraints.
  ///
  /// The return status can be one of the following:
  /// - [LayoutResult.done]: the layout is finished;
  /// - [LayoutResult.unfinished]: more calls to [layOutNextLine] are needed;
  /// - [LayoutResult.didNotAdvance]: the amount of space provided is too small
  ///   to place any amount of text. The caller should supply a larger value of
  ///   `right - left` next time. No new lines were stored in [lines].
  LayoutResult layOutNextLine(LineMetrics bounds);

  /// Returns information about the laid out lines in a multiline [TextElement].
  ///
  /// For a single-line text element this should return null, and the class
  /// itself should implement the [TextLine] interface.
  List<TextLine>? get lines => null;

  TextLine get lastLaidOutLine => lines?.last ?? (this as TextLine);

  /// Renders the text on the [canvas], at positions determined during the
  /// layout.
  ///
  /// This method should only be invoked after the text was laid out.
  ///
  /// In order to render the text at a different location, consider applying a
  /// translation transform to the canvas.
  void render(Canvas canvas);

  /// Clears all current layout information. After this call the text should be
  /// ready to be laid out again.
  void resetLayout();
}

enum LayoutResult {
  didNotAdvance,
  unfinished,
  done,
}
