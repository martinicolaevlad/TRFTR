import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'interactive_maps_marker.dart';

class InteractiveMapsController {
  InteractiveMapsMarkerState? _state;

  InteractiveMapsMarkerState? get state => _state;

  void currentState(InteractiveMapsMarkerState state) {
    _state = state;
  }

  void setCurrentMarker(String id) {
    if (_state != null) {
      _state?.setIndex(id);
    }
  }

  void rebuild([String? id]) {
    _state?.setState(() {
      _state?.setIndex(id ?? _state?.currentMarkerId ?? '');
    });
  }

  void reset({String? id}) {
    Future.delayed(Duration(milliseconds: 200)).then((value) {
      int pageIndex = _state?.widget.items.indexWhere((item) => item.id == (id ?? _state?.currentMarkerId ?? '')) ?? 0;
      _state?.pageController.jumpToPage(pageIndex);
      _state?.rebuildMarkers(id ?? _state?.currentMarkerId ?? '');
      getMapController()?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _state!.markers.firstWhere((marker) => marker.markerId.value == (id ?? _state?.currentMarkerId), orElse: () => Marker(markerId: MarkerId(''))).position, zoom: _state!.widget.zoomFocus),
        ),
      );
    });
  }

  GoogleMapController? getMapController() {
    if (_state != null) {
      return _state?.mapController;
    }
    return null;
  }
}
