import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../supabase_client.dart';

class SaveContactPopupPage extends StatefulWidget {
  final VoidCallback onContactSaved;

  const SaveContactPopupPage({super.key, required this.onContactSaved});

  @override
  State<SaveContactPopupPage> createState() => _SaveContactPopupPageState();
}

class _SaveContactPopupPageState extends State<SaveContactPopupPage> {
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final contactEmailController = TextEditingController();
  final relationshipController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> _saveContact() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final contact = {
      'user_id': user.id,
      'name': contactNameController.text,
      'phone': contactPhoneController.text,
      'email': contactEmailController.text,
      'relation': relationshipController.text,
      'address': addressController.text,
    };

    final response = await http.post(
      Uri.parse('http://192.168.58.192:5000/contacts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop(); // Close popup
      widget.onContactSaved(); // Refresh contact list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save contact")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Emergency Contact"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: contactNameController,
              decoration: const InputDecoration(labelText: "Contact Name"),
            ),
            TextField(
              controller: contactPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: contactEmailController,
              decoration: const InputDecoration(labelText: "Contact Email"),
            ),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(labelText: "Relation"),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saveContact, child: const Text("Save")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
