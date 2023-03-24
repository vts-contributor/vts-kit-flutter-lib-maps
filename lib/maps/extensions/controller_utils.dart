import 'package:flutter/services.dart';
import 'package:maps_core/log/log.dart';
import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:vtmap_gl/vtmap_gl.dart';

extension MapboxControllerExtension on MapboxMapController {

  ///- name: store to the controller with this name. Ex: "dogImg" => linePattern: "dogImg"
  ///- path: asset file path. Ex: "assets/dogImg.png"
  Future<bool> addImageFromAsset(String name, String path) async{
    try {
      await addImage(name, await rootBundle.loadImageAsUint8List(path));
      return true;
    } catch (e, s) {
      Log.e("VTMAP MAP BOX CONTROLLER:", "failed to add image $name from asset with $path", stackTrace: s);
      return false;
    }
  }
}