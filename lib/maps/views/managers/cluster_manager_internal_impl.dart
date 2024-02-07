part of core_map;

class _ClusterManagerImpl extends ChangeNotifier
    implements _ClusterMarkerManagerInternal {
  final Set<MarkerCover> _markers = {};

  double lastZoomLevel = 0;

  ClusterManager _clusterManager = _DefaultClusterManager();

  CoreMapController? mapController;

  _ClusterManagerImpl(Set<Marker>? markers, [ClusterManager? clusterManager]) {
    _initSetMarker(markers);

    if (clusterManager != null) {
      _clusterManager = clusterManager;
    }
  }

  void _initSetMarker(Set<Marker>? markers) {
    if (markers != null && markers.isNotEmpty) {
      _markers.clear();
      _markers.addAll(markers.map((marker) {
        if (marker is MarkerCover) {
          return marker;
        } else {
          return marker.toMarkerCover();
        }
      }));
    }
  }

  void _updateMarkers(Set<Marker>? markers) {
    _initSetMarker(markers);
  }

  void _updateCustomClusterManager(ClusterManager? clusterManager) {
    if (clusterManager != null) {
      _clusterManager = clusterManager;
    }
  }

  @override
  void notifyCameraIdle(double zoom, Set<Marker>? markers) {
    if (zoom != lastZoomLevel) {
      createClusters(zoom, markers);
      lastZoomLevel = zoom;
    }
  }

  @override
  void createClusters(double zoom, Set<Marker>? markers) {
    // check if has change in set marker
    bool isChange = false;

    // init markers
    _initSetMarker(markers);

    // ** when click zoom <=> (2^zoom) * 256
    final double zoomSpecificSpan =
        _clusterManager.maxDistanceAtZoom / pow(2, zoom) / 256;

    // Check if markers of cluster are out of bounds. If true, then add these markers to set markers and remove cluster.
    for (int i = 0; i < _markers.length; i++) {
      MarkerCover marker = _markers.elementAt(i);
      if (marker is Cluster) {
        for (int j = 0; j < marker.markerSet.length; j++) {
          marker.markerSet.elementAt(j).bound = marker.markerSet
              .elementAt(j)
              .point
              ?.toBoundFromSpan(zoomSpecificSpan);
        }

        BoundMarker searchBound =
            marker.markerSet.elementAt(marker.markerSet.length - 1).bound!;

        // search to check if any markers of cluster are out of bounds
        bool isRemoveCluster = false;
        for (int j = 0; j < marker.markerSet.length - 1; j++) {
          if (!searchBound
              .intersectBound(marker.markerSet.elementAt(j).bound!)) {
            isRemoveCluster = true;
            break;
          }
        }

        // add these marker to set markers and remove cluster
        if (isRemoveCluster) {
          for (int k = 0; k < marker.markerSet.length; k++) {
            marker.markerSet.elementAt(k).isClustered = false;
            _markers.add(marker.markerSet.elementAt(k));
          }
          marker.isClustered = true;
          isChange = true;
        }
      }
    }

    // search markers overlap and group them into cluster
    for (int i = 0; i < _markers.length - 1; i++) {
      if (!_markers.elementAt(i).isCanCluster || _markers.elementAt(i).isClustered) {
        continue;
      }

      BoundMarker searchBound =
          _markers.elementAt(i).point!.toBoundFromSpan(zoomSpecificSpan);
      _markers.elementAt(i).bound = searchBound;

      Set<MarkerCover> markerSet = <MarkerCover>{};

      // search markers overlap
      for (int j = i + 1; j < _markers.length; j++) {
        if (!_markers.elementAt(j).isCanCluster || _markers.elementAt(j).isClustered) {
          continue;
        }

        _markers.elementAt(j).bound =
            _markers.elementAt(j).point!.toBoundFromSpan(zoomSpecificSpan);

        if (searchBound.intersectBound(_markers.elementAt(j).bound!)) {
          _markers.elementAt(j).isClustered = true;
          markerSet.add(_markers.elementAt(j));
        }
      }

      if (markerSet.isNotEmpty) {
        _markers.elementAt(i).isClustered = true;
        markerSet.add(_markers.elementAt(i));

        // create centroid
        LatLng centroid =
            markerSet.map((e) => e.positionMarkerCover).toList().getCentroid()!;

        // create cluster
        String idCluster =
            'cluster-d05d6423-55fa-4351-83a2-5ba76bcaca96${DateTime.now().millisecond}$i';

        Cluster cluster = Cluster(
          id: MarkerId(idCluster),
          position: centroid,
          positionMarkerCover: centroid,
          markerSet: markerSet,
          onTap: () {
            _zoomCluster(markerSet.map((marker) => marker.positionMarkerCover).toList());
          },
        );

        // get custom data
        ClusterData? clusterData = getCustomClusterData(cluster, markerSet);

        if (clusterData != null) {
          cluster = cluster.copyFromCLusterData(clusterData);
        }
        cluster.markerSet.addAll(markerSet);

        // add cluster to set marker
        _markers.add(cluster);

        isChange = true;
      }
    }

    if (isChange) {
      notifyListeners();
    }
  }

  Set<Marker> _getSetMarkerAfterClustered() {
    // filter markers clustered
    return _markers
        .where((markerCover) => markerCover.isClustered == false)
        .toSet();
  }

  CoreMapShapes _filterCluster(CoreMapShapes? originalShape) {
    CoreMapShapes shapes = originalShape ?? CoreMapShapes();

    if (_markers.isNotEmpty) {
      shapes.markers.clear();
      shapes.markers.addAll(_getSetMarkerAfterClustered());
    }

    return shapes;
  }

  // custom cluster data
  @override
  ClusterData? getCustomClusterData(
      Cluster cluster, Set<MarkerCover> setMarker) {
    return _clusterManager.customCluster(
        cluster, _getAllMarkerFromSetMarkerCover(setMarker));
  }

  Set<Marker> _getAllMarkerFromSetMarkerCover(Set<MarkerCover> setMarker) {
    Set<Marker> setAllMarker = {};
    for (MarkerCover markerCover in setMarker) {
      setAllMarker.addAll(_getAllMarkerOfMarkerCover(markerCover));
    }
    return setAllMarker;
  }

  Set<Marker> _getAllMarkerOfMarkerCover(MarkerCover marker) {
    Set<Marker> setAllMarker = {};
    if (marker is Cluster) {
      for (MarkerCover markerCover in marker.markerSet) {
        setAllMarker.addAll(_getAllMarkerOfMarkerCover(markerCover));
      }
    } else {
      setAllMarker.add(marker);
    }
    return setAllMarker;
  }

  // zoom cluster to see marker inside
  void _zoomCluster(List<LatLng> listPositionMarker) {
    if (mapController == null) {
      return;
    }

    mapController?.animateCameraToCenterOfPoints(listPositionMarker, 150, duration: 1);
  }
}
