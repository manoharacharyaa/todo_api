import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.maxLines,
    required this.controller,
   
  });

  final String hintText;
  final int? maxLines;
  final TextEditingController controller;
  

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: Colors.indigoAccent,
        decoration: InputDecoration(
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 20,
          ),
          border: InputBorder.none,
          fillColor: const Color.fromARGB(255, 44, 44, 45),
        ),
      ),
    );
  }
}
