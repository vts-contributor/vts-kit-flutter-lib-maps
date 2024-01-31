library screenshot;

// import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

///
///
///Cannot capture Platformview due to issue https://github.com/flutter/flutter/issues/25306
///
///
class WidgetConverter {
  late GlobalKey _containerKey;

  WidgetConverter() {
    _containerKey = GlobalKey();
  }

  ///
  /// Value for [delay] should increase with widget tree size. Prefered value is 1 seconds
  ///
  ///[context] parameter is used to Inherit App Theme and MediaQuery data.
  ///
  ///
  ///
  Future<Uint8List> widgetToBitmap(
      Widget widget, {
        Duration delay = const Duration(seconds: 1),
        double? pixelRatio,
        BuildContext? context,
        Size? targetSize,
      }) async {
    ui.Image image = await widgetToUiImage(widget,
        delay: delay,
        pixelRatio: pixelRatio,
        context: context,
        targetSize: targetSize);
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return byteData!.buffer.asUint8List();
  }

  /// If you are building a desktop/web application that supports multiple view. Consider passing the [context] so that flutter know which view to capture.
  static Future<ui.Image> widgetToUiImage(
      Widget widget, {
        Duration delay = const Duration(seconds: 1),
        double? pixelRatio,
        BuildContext? context,
        Size? targetSize,
      }) async {
    ///
    ///Retry counter
    ///
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      ///
      ///Inherit Theme and MediaQuery of app
      ///
      ///
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              color: Colors.transparent,
              child: child,
            )),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    Size logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    Size imageSize = ui.window.physicalSize;

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
        imageSize.aspectRatio
            .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

    final RenderView renderView = RenderView(
      view: ui.window,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(
        focusManager: FocusManager(),
        onBuildScheduled: () {
          ///
          ///current render is dirty, mark it.
          ///
          isDirty = true;
        });

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
    RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        )).attachToRenderTree(
      buildOwner,
    );
    ////
    ///Render Widget
    ///
    ///

    buildOwner.buildScope(
      rootElement,
    );
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      ///
      ///Reset the dirty flag
      ///
      ///
      isDirty = false;

      image = await repaintBoundary.toImage(
          pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      ///
      ///This delay sholud increas with Widget tree Size
      ///

      await Future.delayed(delay);

      ///
      ///Check does this require rebuild
      ///
      ///
      if (isDirty) {
        ///
        ///Previous capture has been updated, re-render again.
        ///
        ///
        buildOwner.buildScope(
          rootElement,
        );
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;

      ///
      ///retry untill capture is successfull
      ///
    } while (isDirty && retryCounter >= 0);
    try {
      /// Dispose All widgets
      // rootElement.visitChildren((Element element) {
      //   rootElement.deactivateChild(element);
      // });
      buildOwner.finalizeTree();
    } catch (e) {}

    return image; // Adapted to directly return the image and not the Uint8List
  }

  ///
  /// ### This function will calculate the size of your widget and then captures it.
  ///
  /// ## Notes on Usage:
  ///     1. Do not use any scrolling widgets like ListView,GridView. Convert those widgets to use Columns and Rows.
  ///     2. Do not Widgets like `Flexible`,`Expanded`, or `Spacer`. If you do Please consider passing constraints.
  ///
  /// Params:
  ///
  /// [widget] : The Widget which needs to be captured.
  ///
  /// [delay] : Value for [delay] should increase with widget tree size. Preferred value is 1 seconds
  ///
  /// [context] : parameter is used to Inherit App Theme and MediaQuery data.
  ///
  /// [constraints] : Constraints for your image. Pass this parameter if your widget contains `Scaffold`,`Expanded`,`Flexible`,`Spacer` or any other widget which needs constraint of parent.
  ///
  ///
  ///
  Future<Uint8List> captureFromLongWidget(
      Widget widget, {
        Duration delay = const Duration(seconds: 1),
        double? pixelRatio,
        BuildContext? context,
        BoxConstraints? constraints,
      }) async {
    ui.Image image = await longWidgetToUiImage(
      widget,
      delay: delay,
      pixelRatio: pixelRatio,
      context: context,
      constraints: constraints ?? BoxConstraints(),
    );
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image> longWidgetToUiImage(Widget widget,
      {Duration delay = const Duration(seconds: 1),
        double? pixelRatio,
        BuildContext? context,
        BoxConstraints constraints = const BoxConstraints(
          maxHeight: double.maxFinite,
        )}) async {
    final PipelineOwner pipelineOwner = PipelineOwner();
    final _MeasurementView rootView =
    pipelineOwner.rootNode = _MeasurementView(constraints);
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> element =
    RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: 'root_render_element_for_size_measurement',
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);
    try {
      rootView.scheduleInitialLayout();
      pipelineOwner.flushLayout();

      ///
      /// Calculate Size, and capture widget.
      ///

      return widgetToUiImage(
        widget,
        targetSize: rootView.size,
        context: context,
        delay: delay,
        pixelRatio: pixelRatio,
      );
    } finally {
      // Clean up.
      element
          .update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
      buildOwner.finalizeTree();
    }
  }
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

///
/// RenderBox widget to calculate size.
///
class _MeasurementView extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  final BoxConstraints boxConstraints;
  _MeasurementView(this.boxConstraints);

  @override
  void performLayout() {
    assert(child != null);
    child!.layout(boxConstraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}