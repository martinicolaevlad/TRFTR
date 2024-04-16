import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../blocs/log_in_bloc/log_in_bloc.dart';
import '../../components/textfield.dart';
import '../../components/strings.dart';


class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();

}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _errorMsg;
  bool obscurePassword = true;
  IconData iconPassword = FontAwesomeIcons.solidEye;
  bool signInRequired = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogInBloc, LogInState>(
      listener: (context, state) {
        if(state is LogInSuccess) {
        setState(() {
          signInRequired = false;
        });
      } else if(state is LogInProcess) {
        setState(() {
          signInRequired = true;
        });
      } else if(state is LogInFailure) {
        setState(() {
          signInRequired = false;
          _errorMsg = 'Invalid email or password';
        });
      }
      },
      child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                child: MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(FontAwesomeIcons.envelope),
                    errorMsg: _errorMsg,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else
                      if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(
                          val)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    }
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: const Icon(FontAwesomeIcons.key),
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    } else if (!passwordRexExp.hasMatch(val)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                        if (obscurePassword) {
                          iconPassword = FontAwesomeIcons.solidEye;
                        } else {
                          iconPassword = FontAwesomeIcons.solidEyeSlash;
                        }
                      });
                    },
                    icon: Icon(iconPassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              !signInRequired
                  ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50,
                child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<LogInBloc>().add(LogInRequired(
                            emailController.text,
                            passwordController.text));
                      }
                    },
                    style: TextButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Text(
                        'Log In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
              )
              : const CircularProgressIndicator()
            ],
          ),
        ),
    );
      }
}
