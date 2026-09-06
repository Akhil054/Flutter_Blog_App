import 'package:blog_app/theme/pallete.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;


  const AuthButton({super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [
              AppPalette.gradient2, AppPalette.gradient2
            ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        /// Event
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(395, 55),
            backgroundColor: AppPalette.transparantColor,
            shadowColor: AppPalette.transparantColor,
          ),
          child: Text(
            buttonText,
          style: const TextStyle(
            /// gradient1/gradient2 (the button's background) are mid-to-dark
            /// muted tones - black reads far better on them than white does
            color: AppPalette.blackColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),),

      ),
    );
  }
}
