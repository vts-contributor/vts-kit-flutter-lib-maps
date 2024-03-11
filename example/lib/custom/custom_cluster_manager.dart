import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:maps_core/maps.dart';

class CustomClusterManager implements ClusterManager {
  @override
  int maxDistanceAtZoom = 25;

  @override
  ClusterData? customCluster({required Cluster cluster, required Set<Marker> setAllMarkerOfCluster}) {
    Widget? custom = Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 241, 241),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4), 
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue, 
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              setAllMarkerOfCluster.length.toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ), // inner content
        ),
      ),
    );

    log("custom cluster");

    return ClusterData(
      icon: MarkerIcon.fromWidget('${cluster.id}icon', custom),
      expandOnTap: true,
    );
  }

  InfoWindow? customInfoWindowCluster(Set<Marker> setMarker, double zoomLevel) {
    log("zoom level: $zoomLevel");

    return InfoWindow(
      widget: Container(
        height: 50,
        width: 50,
        color: Colors.blue,
        child: const Text("123"),
      ),
    );
  }
  
  @override
  bool isTryBreakCluster = true;
}