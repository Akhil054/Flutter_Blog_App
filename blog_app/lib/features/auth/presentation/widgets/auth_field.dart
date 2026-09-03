import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {

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
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  /// tracks whether the password is currently hidden; only relevant
  /// when the field was created with isObsecureText true
  late bool _obscureText = widget.isObsecureText;

  @override
  Widget build(BuildContext context) {
    /// coz entier filed is of Form
    return TextFormField(
      /// passed the controller
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        /// eye icon to toggle password visibility - shown only on password fields
        suffixIcon: widget.isObsecureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      /// Validates the input field from signup page so we use the validator
      validator:(value){
        /// Giving an condition i.e if user is not given any vlaues
        if(value!.isEmpty){
          return "${widget.hintText} is missing !";
        }
        /// If everything is correct
        return null;
      },
      obscureText: _obscureText,
      // obscuringCharacter: '*',
    );
  }
}
