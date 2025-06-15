import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// This is a utility class to generate an app icon.
/// It's not used in the actual app, but can be used to generate an icon
/// if you don't have a designer or graphic tool available.
class AppIconGenerator {
  static Future<void> generateAppIcon() async {
    // Create a widget that represents our icon
    final iconWidget = Container(
      width: 1024,
      height: 1024,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7DE2FF), Color(0xFF5D7EFF)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(Icons.video_call_rounded, size: 600, color: Colors.white),
      ),
    );

    // Create a RepaintBoundary to capture the widget as an image
    final repaintBoundary = RepaintBoundary(child: iconWidget);

    // Create a pipeline owner and build context
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: RenderBox(),
      widget: repaintBoundary,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final renderObject =
        rootElement.findRenderObject() as RenderRepaintBoundary;
    final image = await renderObject.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Save the image to a file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/app_icon.png');
    await file.writeAsBytes(pngBytes);

    print('App icon saved to: ${file.path}');
  }
}
