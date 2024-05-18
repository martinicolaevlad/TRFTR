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
  ScrollPhysics _scrollPhysics = const BouncingScrollPhysics(); // Default scroll physics
  String? _imagePath;


  @override
  void initState() {
    super.initState();
    initializeShopDetails();
  }



  void _onMapLongPress(LatLng position) {
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
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
    // Pick an image from the gallery or camera
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    log(image!.path.toString());
    setState(() {
      _imagePath = image.path;
      _pictureController.text = _imagePath!;
    });

  }


  void _fillFormWithExistingDetails() {
    _nameController.text = shop?.name ?? '';

    // Check if shop.openTime is not null and format it
    if (shop?.openTime != null) {
      _openTimeController.text = '${(shop!.openTime ~/ 100).toString().padLeft(2, '0')}:${(shop!.openTime % 100).toString().padLeft(2, '0')}';
    } else {
      _openTimeController.text = ''; // Set default or leave blank if no time is set
    }

    // Check if shop.closeTime is not null and format it
    if (shop?.closeTime != null) {
      _closeTimeController.text = '${(shop!.closeTime ~/ 100).toString().padLeft(2, '0')}:${(shop!.closeTime % 100).toString().padLeft(2, '0')}';
    } else {
      _closeTimeController.text = ''; // Set default or leave blank if no time is set
    }

    _latitudeController.text = shop?.latitude ?? '';
    _longitudeController.text = shop?.longitude ?? '';
    _nextDropController.text = shop?.nextDrop != null ? DateFormat('dd.MM.yyyy').format(shop!.nextDrop!) : '';
    _imagePath = shop!.picture.toString() ?? '';
    _detailsController.text = shop!.details ?? '';

  }

  Widget buildImageWidget(String path) {
    // Check if the path is a URL
    if (path.startsWith('http') || path.startsWith('https')) {
      // It's a URL
      return Image.network(
        path,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(CupertinoIcons.photo, size: 100),
      );
    } else {
      // It's a local file
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
      appBar: AppBar(
        title: Text("My Shop", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold
        ),),
        centerTitle: true
      ),
      body: SingleChildScrollView(
        physics: _scrollPhysics, // Apply dynamic scroll physics here
        padding: const EdgeInsets.all(20),
        child: buildForm(),
      )
    );
  }

  Widget buildForm() {
    return Column(
      children: [
        SizedBox(height: 10),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _imagePath != null && _imagePath!.isNotEmpty
                ? buildImageWidget(_imagePath!)
                : SizedBox(
              height: 300,
              width: double.infinity,
              child: Icon(CupertinoIcons.camera, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: FloatingActionButton(
                onPressed: _pickImage,
                child: Icon(Icons.edit),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text("Shop's Name:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "type here",
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
        SizedBox(height: 10),
        Text("Next Drop:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        DateInputWidget(
          controller: _nextDropController,
          hintText: "Next Drop",
        ),
        SizedBox(height: 10),
        Text("Details:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        TextField(
          controller: _detailsController,
          textAlign: TextAlign.center,
          inputFormatters: [
            MaxLinesTextInputFormatter(2),
          ],
          decoration: InputDecoration(
            hintText: "type here",
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
          maxLength: 90,
          maxLines: 2,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text("Open Time:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                border: Border.all(color: Colors.grey), // Border color
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(46.7, 23.6),
                    zoom: 10,
                  ),
                  markers: shop != null ? {
                    Marker(
                      markerId: MarkerId("shopLocation"),
                      position: LatLng(double.parse(_latitudeController.text.isEmpty ? shop!.latitude : _latitudeController.text),
                          double.parse(_longitudeController.text.isEmpty ? shop!.longitude : _longitudeController.text)),
                    )
                  }: {},
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
                  ],
                )),
            SizedBox(width: 10),
            Expanded(
                child: Column(
                  children: [
                    Text("Longitude:", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    TextField(
                      controller: _longitudeController,
                        decoration: InputDecoration(
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
                  ],
                )),
          ],
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
      showErrorDialog('Please enter the shop name.');
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
    // Initialize _selectedDate with the last picked date or current date if none.
    _selectedDate = widget.controller.text.isNotEmpty
        ? DateFormat('dd.MM.yyyy').parse(widget.controller.text)
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textAlign: TextAlign.center,

      readOnly: true, // To prevent manual editing
      onTap: () async {
        // Show date picker on tap
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate, // Use the last selected date or today
          firstDate: DateTime(2000), // First selectable date
          lastDate: DateTime(2101), // Last selectable date
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            // Update the text field with the selected date
            widget.controller.text =
                DateFormat('dd.MM.yyyy').format(_selectedDate);
          });
        }
      },
      decoration: InputDecoration(
        hintText: widget.controller.text.isNotEmpty
            ? widget.controller.text
            : widget.hintText, // Hint text for the text field
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

      readOnly: true, // To prevent manual editing
      onTap: () async {
        // Show time picker on tap
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(), // Initial time
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
            // Update the text field with the selected time
            widget.controller.text = _formatTime(_selectedTime);
          });
        }
      },
      decoration: InputDecoration(
        hintText: widget.controller.text.isNotEmpty
            ? widget.controller.text
            : widget.hintText, // Hint text for the text field
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
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

    // Allow the new value only if it doesn't exceed maxLines
    if (newlineCount < maxLines) {
      return newValue;
    }

    // If new input attempts to exceed maxLines, retain the old value
    return oldValue;
  }
}
