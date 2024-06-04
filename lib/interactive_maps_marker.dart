import 'dart:async';
import 'dart:typed_data';
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/interactive_maps_controller.dart';
export 'package:sh_app/interactive_maps_controller.dart';
import './utils.dart';

class MarkerItem {
  int id;
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
    this.search
  }){
    if(itemBuilder == null && itemContent == null){
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
  InteractiveMapsMarkerState createState() {
    var state = InteractiveMapsMarkerState();
    if(controller != null){
      controller!.currentState(state);
    }
    return state;
  }
}

class InteractiveMapsMarkerState extends State<InteractiveMapsMarker> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  PageController pageController = PageController(viewportFraction: 0.9);
  Set<Marker> markers = {};
  int currentIndex = 0;
  ValueNotifier<int?> selectedMarker = ValueNotifier<int?>(0);

  @override
  void initState() {
    super.initState();
    widget.readIcons().then((_) {
      pageController.addListener(_onPageViewScroll);
      rebuildMarkers(currentIndex);
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
    rebuildMarkers(currentIndex);
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
          valueListenable: selectedMarker,
          builder: (context, value, child) {
            print('Values changed');
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



  Widget _buildItem(BuildContext context, int i) {
    return Transform.scale(
      scale: i == currentIndex ? 1 : 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: widget.itemHeight,
          decoration: BoxDecoration(
              color: Color(0xffffffff),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]
          ),
          child: widget.itemContent!(context, i),
        ),
      ),
    );
  }

  void _pageChanged(int index) {
    setState(() => currentIndex = index);
    rebuildMarkers(index);
  }

  Future<void> rebuildMarkers(int index) async {
    if(widget.items.isEmpty) return;
    int current = widget.items[index].id;

    Set<Marker> _markers = Set<Marker>();

    widget.items.forEach((item) {
      _markers.add(
        Marker(
          markerId: MarkerId(item.id.toString()),
          position: LatLng(item.latitude, item.longitude),
          onTap: () => setIndex(widget.items.indexOf(item)),
          icon: BitmapDescriptor.fromBytes(item.id == current ? widget.markerIconSelected! : widget.markerIcon!),
        ),
      );
    });

    setState(() {
      markers = _markers;
      selectedMarker.value = current;
    });
  }

  void setIndex(int index){
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageViewScroll() {
    var index = pageController.page!.round();
    if (currentIndex != index) {
      _pageChanged(index);
    }
  }
}
