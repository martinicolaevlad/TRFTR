import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sh_app/screens/profile/shop_profile_screen.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/my_user_bloc/my_user_bloc.dart';
import '../../blocs/shop_blocs/create_shop_bloc.dart';

// Ensure all the necessary imports are added

class CreateShopScreen extends StatefulWidget {
  final MyUser myUser;

  const CreateShopScreen(this.myUser, {super.key});

  @override
  _CreateShopScreenState createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  late MyShop shop;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pictureController = TextEditingController();
  final TextEditingController _nextDropController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    shop = MyShop.empty;
    shop.ownerId = context.read<MyUserBloc>().state.user!.id;
    shop.rating = 0;
    shop.lastDrop = DateTime.now();
    shop.latitude = '43.9745';
    shop.longitude = '27.9745';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateShopBloc, CreateShopState>(
      listener: (context, state) {
        if (state is CreateShopSuccess) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              try {
                if (_nameController.text.isNotEmpty) {
                  shop.name = _nameController.text;
                } else {
                  throw Exception("Name is empty!");
                }

                // if (_pictureController.text.isNotEmpty) {
                //   shop.picture = _pictureController.text;
                // } else {
                //   throw Exception("Picture is empty!");
                // }
                // if (_nextDropController.text.isNotEmpty) {
                //   shop.nextDrop.day = _nextDropController.text.;
                // }
                // if (_latitudeController.text.isNotEmpty) {
                //   shop.latitude = double.parse(_latitudeController.text);
                // } else {
                //   throw Exception("Latitude is empty!");
                // }

                // if (_longitudeController.text.isNotEmpty) {
                //   shop.longitude = double.parse(_longitudeController.text);
                // } else {
                //   throw Exception("Longitude is empty!");
                // }

                if (_openTimeController.text.isNotEmpty) {
                  TimeOfDay time = TimeOfDay(
                      hour: int.parse(_openTimeController.text.split(":")[0]),
                      minute: int.parse(_openTimeController.text.split(":")[1])
                  );
                  log(time.hour.toString());
                  String formattedTime = '${time.hour.toString().padLeft(
                      2, '0')}${time.minute.toString().padLeft(2, '0')}';
                  log(formattedTime);
                  shop.openTime = int.parse(formattedTime);
                } else {
                  throw Exception("Open Time is empty!");
                }

                if (_closeTimeController.text.isNotEmpty) {
                  TimeOfDay time = TimeOfDay(
                      hour: int.parse(_closeTimeController.text.split(":")[0]),
                      minute: int.parse(_closeTimeController.text.split(":")[1])
                  );

                  String formattedTime = '${time.hour.toString().padLeft(
                      2, '0')}${time.minute.toString().padLeft(2, '0')}';
                  shop.closeTime = int.parse(formattedTime);
                } else {
                  throw Exception("Close Time is empty!");
                }
                log(shop.toString());
                context.read<CreateShopBloc>().add(CreateShop(shop));
                ShopProfileScreen(shop: shop);
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text(e.toString()),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              }

            },
            child: const Icon(CupertinoIcons.add),
          ),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true, // Centers the AppBar title
            title: const Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 22,
                )
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "It's time to create your shop's own page.",
                  style: TextStyle(
                    fontSize: 19, // Adjust the font size according to your design
                    fontWeight: FontWeight.bold, // Makes text bold
                  ),
                  textAlign: TextAlign.center, // Ensures the text is centered
                ),
                const Text(
                  "(* fields are mandatory)",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "Shop's Name: *",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type here',
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  "Next drop:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DateInputWidget(
                  controller: _nextDropController,
                  hintText: "Select date",
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded( // Ensuring the column takes up equal horizontal space
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // To size the column to the height of its children
                        children: [
                          const Text(
                            "Open Time: *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TimeInputWidget(
                            controller: _openTimeController,
                            hintText: "Select Time",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20), // Spacing between the two columns
                    Expanded( // Ensuring the column takes up equal horizontal space
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // To size the column to the height of its children
                        children: [
                          const Text(
                            "Close Time: *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TimeInputWidget(
                            controller: _closeTimeController,
                            hintText: "Select Time",
                          ),
                        ],
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
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
