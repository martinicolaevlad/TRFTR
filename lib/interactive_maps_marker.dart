import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/interactive_maps_controller.dart';
export 'package:sh_app/interactive_maps_controller.dart';
import './utils.dart';

class MarkerItem {
  String id;
  double latitude;
  double longitude;
  String? search;

  MarkerItem({required this.id, required this.latitude, required this.longitude});
}

class InteractiveMapsMarker extends StatefulWidget {
  final LatLng center;
  final double itemHeight;
  final double zoom;
  final double zoomFocus;
  final bool zoomKeepOnTap;
  final String? search;
  List<MarkerItem> items;
  final IndexedWidgetBuilder? itemContent;
  final IndexedWidgetBuilder? itemBuilder;
  final EdgeInsetsGeometry itemPadding;
  final Alignment contentAlignment;
  InteractiveMapsController? controller;
  VoidCallback? onLastItem;

  InteractiveMapsMarker({
    Key? key,
    required this.items,
    this.itemBuilder,
    this.center = const LatLng(0.0, 0.0),
    this.itemContent,
    this.itemHeight = 116,
    this.zoom = 12.0,
    this.zoomFocus = 15.0,
    this.zoomKeepOnTap = false,
    this.itemPadding = const EdgeInsets.only(bottom: 80.0),
    this.contentAlignment = Alignment.bottomCenter,
    this.controller,
    this.onLastItem,
    this.search,
  }) : super(key: key) {
    if (itemBuilder == null && itemContent == null) {
      throw Exception('itemBuilder or itemContent must be provided');
    }
    readIcons();
  }

  Future<void> readIcons() async {
    Completer<void> completer = Completer();
    try {
      if (markerIcon == null) {
        markerIcon = await getBytesFromAsset('assets/location.png', 120);
      }
      if (markerIconSelected == null) {
        markerIconSelected = await getBytesFromAsset('assets/location_selected.png', 120);
      }
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  Uint8List? markerIcon;
  Uint8List? markerIconSelected;

  @override
  InteractiveMapsMarkerState createState() => InteractiveMapsMarkerState();
}

class InteractiveMapsMarkerState extends State<InteractiveMapsMarker> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  PageController pageController = PageController(viewportFraction: 0.9);
  Set<Marker> markers = {};
  String? currentMarkerId;

  @override
  void initState() {
    super.initState();
    widget.readIcons().then((_) {
      pageController.addListener(_onPageViewScroll);
      if (widget.items.isNotEmpty) {
        rebuildMarkers(widget.items.first.id);
      }
    }).catchError((error) {
      print('Failed to load icons: $error');
    });
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageViewScroll);
    pageController.dispose();
    _controller.future.then((mapController) => mapController.dispose());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.items.isNotEmpty && currentMarkerId != null) {
      rebuildMarkers(currentMarkerId!);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildMap(),
        Align(
          alignment: widget.contentAlignment,
          child: Padding(
            padding: widget.itemPadding,
            child: SizedBox(
              height: widget.itemHeight,
              child: PageView.builder(
                itemCount: widget.items.length,
                controller: pageController,
                onPageChanged: _pageChanged,
                itemBuilder: widget.itemBuilder ?? _buildItem,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMap() {
    return Positioned.fill(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ValueListenableBuilder(
          valueListenable: ValueNotifier(currentMarkerId),
          builder: (context, value, child) {
            return GoogleMap(
              zoomControlsEnabled: false,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.center,
                zoom: widget.zoom,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    MarkerItem item = widget.items[index];
    return Transform.scale(
      scale: item.id == currentMarkerId ? 1 : 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: widget.itemHeight,
          decoration: BoxDecoration(
              color: Color(0xffffffff),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
          child: widget.itemContent!(context, index),
        ),
      ),
    );
  }

  void _pageChanged(int index) {
    String id = widget.items[index].id;
    setState(() => currentMarkerId = id);
    rebuildMarkers(id);
  }

  Future<void> rebuildMarkers(String id) async {
    Set<Marker> _markers = {};
    for (var item in widget.items) {
      _markers.add(
        Marker(
          markerId: MarkerId(item.id),
          position: LatLng(item.latitude, item.longitude),
          onTap: () => setIndex(item.id),
          icon: BitmapDescriptor.fromBytes(item.id == id
              ? widget.markerIconSelected!
              : widget.markerIcon!),
        ),
      );
    }
    setState(() {
      markers = _markers;
    });
  }

  void setIndex(String id) {
    int index = widget.items.indexWhere((item) => item.id == id);
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageViewScroll() {
    if (pageController.page != null) {
      int index = pageController.page!.round();
      String id = widget.items[index].id;
      if (currentMarkerId != id) {
        _pageChanged(index);
      }
    }
  }

  void focusOnSelectedShop(String shopId) {
    int index = widget.items.indexWhere((item) => item.id == shopId);
    if (index != -1) {
      MarkerItem selectedShop = widget.items[index];
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(selectedShop.latitude, selectedShop.longitude),
            zoom: 15.0,  // Adjust zoom level as needed
          ),
        ),
      );
      pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentMarkerId = shopId;
      });
    }
  }
}
