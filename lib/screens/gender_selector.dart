import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  GenderSelector({this.selectedGender, required this.onGenderSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(labelText: "Gender"),
      items: ["Male", "Female", "Other"]
          .map((gender) => DropdownMenuItem(
        value: gender,
        child: Text(gender),
      ))
          .toList(),
      onChanged: (value) => onGenderSelected(value!),
      validator: (value) => value == null ? "Please select a gender" : null,
    );
  }
}