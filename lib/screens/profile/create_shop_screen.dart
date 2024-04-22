import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:intl/intl.dart';

import '../../blocs/log_in_bloc/log_in_bloc.dart';
import '../../blocs/shop_blocs/create_shop_bloc.dart';

class CreateShopScreen extends StatefulWidget {
  final MyUser myUser;
  const CreateShopScreen(this.myUser,{super.key});

  State<CreateShopScreen> createState() => _CreateShopScreenState();

}

class _CreateShopScreenState extends State<CreateShopScreen>{
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
    shop = MyShop.empty;
    shop.ownerId = context.read<MyUserBloc>().state.user!.id;
    shop.rating = 0;
    shop.lastDrop = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateShopBloc, CreateShopState>(listener: (context, state){
      if(state is CreateShopSuccess){
        Navigator.pop(context);
      }
    },
    child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(_nameController.text.length != 0) {
              setState(() {
                shop.name = _nameController.text;
              });
              context.read<CreateShopBloc>().add(CreateShop(shop));

            }
          },
          child: const Icon(CupertinoIcons.add),
        ),
        appBar: AppBar(
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
              "Your shop's name"
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                  controller: _nameController,
                  maxLines: 1,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "Your shop's name:",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                    ),
                  ),
                              ),
                  SizedBox(height: 10), // Adding space between widgets
                  // Replace TextField with DateInputWidget
                  DateInputWidget(
                    controller: _nextDropController,
                    hintText: "When is your next drop?",
                  ),
                  TextField(
                  controller: _nameController,
                  maxLines: 1,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "Your shop's name:",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                    ),
                  ),
                              ),

                ],
              ),
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
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true, // To prevent manual editing
      onTap: () async {
        // Show date picker on tap
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(), // Initial date
          firstDate: DateTime(2000), // First selectable date
          lastDate: DateTime(2101), // Last selectable date
        );
        if (pickedDate != null && pickedDate != _selectedDate) {
          setState(() {
            _selectedDate = pickedDate;
            // Update the text field with the selected date
            widget.controller.text =
                DateFormat('yyyy-MM-dd').format(_selectedDate);
          });
        }
      },
      decoration: InputDecoration(
        hintText: widget.hintText, // Hint text for the text field
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