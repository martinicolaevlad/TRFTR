import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/my_user_bloc/my_user_bloc.dart';
import '../../blocs/shop_blocs/create_shop_bloc.dart';
import '../../blocs/shop_blocs/get_shop_bloc.dart';
import '../../blocs/shop_blocs/update_shop_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateShopScreen extends StatefulWidget {
  final MyUser myUser;
  const CreateShopScreen(this.myUser, {super.key});
  @override
  _CreateShopScreenState createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  MyShop? shop;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pictureController = TextEditingController();
  final TextEditingController _nextDropController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final FirebaseShopRepo _shopRepo = FirebaseShopRepo();
  ScrollPhysics _scrollPhysics = const BouncingScrollPhysics();
  String? _imagePath;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    initializeShopDetails();
  }

  void _onMapLongPress(LatLng position) {
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
      markers.add(Marker(
        markerId: MarkerId("selectedLocation"),
        position: position,
        infoWindow: InfoWindow(title: 'Selected Shop Location'),
      ));
    });
  }

  void initializeShopDetails() async {
    var fetchedShop = await _shopRepo.getShopByOwnerId(widget.myUser.id);
    if (fetchedShop != null) {
      setState(() {
        shop = fetchedShop;
        _fillFormWithExistingDetails();
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    log(image!.path.toString());
    setState(() {
      _imagePath = image.path;
      _pictureController.text = _imagePath!;
    });
  }

  void _fillFormWithExistingDetails() {
    _nameController.text = shop?.name ?? '';
    if (shop?.openTime != null) {
      _openTimeController.text = '${(shop!.openTime ~/ 100).toString().padLeft(2, '0')}:${(shop!.openTime % 100).toString().padLeft(2, '0')}';
    } else {
      _openTimeController.text = '';
    }
    if (shop?.closeTime != null) {
      _closeTimeController.text = '${(shop!.closeTime ~/ 100).toString().padLeft(2, '0')}:${(shop!.closeTime % 100).toString().padLeft(2, '0')}';
    } else {
      _closeTimeController.text = '';
    }
    _latitudeController.text = shop?.latitude ?? '';
    _longitudeController.text = shop?.longitude ?? '';
    _nextDropController.text = shop?.nextDrop != null ? DateFormat('dd.MM.yyyy').format(shop!.nextDrop!) : '';
    _imagePath = shop!.picture.toString();
    _detailsController.text = shop!.details ?? '';
  }

  Widget buildImageWidget(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.photo, size: 100),
      );
    } else {
      return Image.file(
        File(path),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("My Shop", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            centerTitle: true
        ),
        body: SingleChildScrollView(
          physics: _scrollPhysics,
          padding: const EdgeInsets.all(20),
          child: buildForm(),
        )
    );
  }

  Widget buildForm() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _imagePath != null && _imagePath!.isNotEmpty ? buildImageWidget(_imagePath!) : const SizedBox(height: 300, width: double.infinity, child: Icon(CupertinoIcons.camera, size: 100)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton(onPressed: _pickImage, child: const Icon(Icons.edit)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Shop's Name:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "type here",
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Next Drop:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        DateInputWidget(
          controller: _nextDropController,
          hintText: "Next Drop",
        ),
        const SizedBox(height: 10),
        const Text("Details:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        TextField(
          controller: _detailsController,
          textAlign: TextAlign.center,
          inputFormatters: [MaxLinesTextInputFormatter(2)],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "type here",
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          maxLength: 90,
          maxLines: 2,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text("Open Time:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  TimeInputWidget(
                    controller: _openTimeController,
                    hintText: "Open Time",
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Text("Close Time:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  TimeInputWidget(
                    controller: _closeTimeController,
                    hintText: "Close Time",
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text("Long press on the map to set the location:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(
          height: 300,
          child: Listener(
            onPointerDown: (PointerDownEvent event) {_disableScroll();},
            onPointerUp: (PointerUpEvent event) {_enableScroll();},
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(46.7, 23.6), zoom: 10),
                  markers: markers,
                  onLongPress: _onMapLongPress,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
            children: [
              Expanded(
                  child: Column(
                      children: [
                        Text("Latitude:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        TextField(
                          controller: _latitudeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ]
                  )
              ),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                      children: [
                        Text("Longitude:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        TextField(
                          controller: _longitudeController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ]
                  )
              ),
            ]
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _saveShopDetails(),
          child: Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            elevation: 3.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
          ),
        ),
      ],
    );
  }

  void _disableScroll() {
    setState(() {
      _scrollPhysics = NeverScrollableScrollPhysics();
    });
  }

  void _enableScroll() {
    setState(() {
      _scrollPhysics = AlwaysScrollableScrollPhysics();
    });
  }

  void _saveShopDetails() async {
    if (!_validateInputs()) {
      return;
    }
    if (shop == null) {
      shop = MyShop.empty;
    }
    shop!.name = _nameController.text;
    shop!.latitude = _latitudeController.text;
    shop!.longitude = _longitudeController.text;
    if(_detailsController.text.isNotEmpty){
      shop!.details = _detailsController.text;
    }
    if (_nextDropController.text.isNotEmpty) {
      shop!.nextDrop = DateFormat('dd.MM.yyyy').parse(_nextDropController.text, true);
    }
    final myUserBloc = context.read<MyUserBloc>();
    if (myUserBloc.state.user != null) {
      shop!.ownerId = myUserBloc.state.user!.id;
    } else {
      return;
    }
    try {
      List<String> openTimeParts = _openTimeController.text.split(':');
      if (openTimeParts.length == 2) {
        shop!.openTime = int.parse(openTimeParts[0]) * 100 + int.parse(openTimeParts[1]);
      }
      List<String> closeTimeParts = _closeTimeController.text.split(':');
      if (closeTimeParts.length == 2) {
        shop!.closeTime = int.parse(closeTimeParts[0]) * 100 + int.parse(closeTimeParts[1]);
      }
    } catch (e) {
      showErrorDialog("Error parsing time: $e");
      return;
    }
    if (_pictureController.text.isNotEmpty) {
      try {
        await _shopRepo.uploadPicture(_pictureController.text, shop!.id);
      } catch (e) {
        showErrorDialog("Failed to upload picture: ${e.toString()}");
        return;
      }
    }
    _shopRepo.getShopByOwnerId(widget.myUser.id).then((existingShop) {
      if (existingShop != null) {
        BlocProvider.of<UpdateShopBloc>(context).add(UpdateShop(
            shopId: existingShop.id,
            name: shop!.name,
            latitude: shop!.latitude,
            longitude: shop!.longitude,
            nextDrop: shop!.nextDrop,
            openTime: shop!.openTime,
            closeTime: shop!.closeTime,
            ownerId: widget.myUser.id,
            details: shop!.details,
            rating: shop!.rating,
            ratingsCount: shop!.ratingsCount
        ));
      } else {
        BlocProvider.of<CreateShopBloc>(context).add(CreateShop(shop!));
      }
      BlocProvider.of<GetShopBloc>(context).add(GetShop());
      Navigator.of(context).pop();
    }).catchError((error) {
      showErrorDialog("Error accessing shop data: $error");
    });
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      showErrorDialog("The shop's name can't be empty.");
      return false;
    }
    if (_openTimeController.text.isEmpty) {
      showErrorDialog('Please enter the open hours.');
      return false;
    }
    if (_closeTimeController.text.isEmpty) {
      showErrorDialog('Please enter the closing hours.');
      return false;
    }
    return true;
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class DateInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  const DateInputWidget({
    required this.controller,
    required this.hintText,
    Key? key,
  }) : super(key: key);

  @override
  _DateInputWidgetState createState() => _DateInputWidgetState();
}

class _DateInputWidgetState extends State<DateInputWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.controller.text.isNotEmpty
        ? DateFormat('dd.MM.yyyy').parse(widget.controller.text)
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textAlign: TextAlign.center,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            widget.controller.text = DateFormat('dd.MM.yyyy').format(_selectedDate);
          });
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: widget.controller.text.isNotEmpty ? widget.controller.text : widget.hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class TimeInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const TimeInputWidget({
    required this.controller,
    required this.hintText,
    Key? key,
  }) : super(key: key);

  @override
  _TimeInputWidgetState createState() => _TimeInputWidgetState();
}

class _TimeInputWidgetState extends State<TimeInputWidget> {
  late TimeOfDay _selectedTime;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textAlign: TextAlign.center,
      readOnly: true,
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (pickedTime != null) {
          setState(() {
            _selectedTime = pickedTime;
            widget.controller.text = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: widget.controller.text.isNotEmpty ? widget.controller.text : widget.hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class MaxLinesTextInputFormatter extends TextInputFormatter {
  final int maxLines;
  MaxLinesTextInputFormatter(this.maxLines);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    int newlineCount = '\n'.allMatches(newText).length;
    if (newlineCount < maxLines) {
      return newValue;
    }
    return oldValue;
  }
}
