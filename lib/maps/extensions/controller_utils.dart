import 'package:flutter/services.dart';
import 'package:maps_core/log/log.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

extension MapboxControllerExtension on MapboxMapController {

  ///- name: store to the controller with this name. Ex: "dogImg" => linePattern: "dogImg"
  ///- path: asset file path. Ex: "assets/dogImg.png"
  Future<bool> addImageFromAsset(String name, String path) async{
    try {
      final ByteData bytes = await rootBundle.load(path);
      final Uint8List list = bytes.buffer.asUint8List();
      await addImage(name, list);
      return true;
    } catch (e, s) {
      Log.e("MAP BOX CONTROLLER EXTENSION:", "failed to add image from asset with $path", stackTrace: s);
      return false;
    }
  }
}