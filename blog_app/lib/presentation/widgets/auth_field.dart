import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {

  /// Created an Constuctor
  final String hintText;
  final TextEditingController controller;
  final bool isObsecureText;  /// used for password hiding purposes

  /// Constructor
  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObsecureText = false,

  });

  @override
  Widget build(BuildContext context) {
    /// coz entier filed is of Form
    return TextFormField(
      /// passed the controller
      controller: controller,
      decoration: InputDecoration(
        hintText:hintText
      ),
      /// Validates the input field from signup page so we use the validator
      validator:(value){
        /// Giving an condition i.e if user is not given any vlaues
        if(value!.isEmpty){
          return "$hintText is missing !";
        }
        /// If everything is correct
        return null;
      },
      obscureText:  isObsecureText,
      // obscuringCharacter: '*',
    );
  }
}
