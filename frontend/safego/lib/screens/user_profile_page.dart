import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabase_client.dart';
import 'save_contact_popup_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  bool isEditing = false;
  Map<String, String> originalData = {};
  List<dynamic> contacts = [];
  String? profileImageUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchContacts();
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.58.129:5000/profile/${user.id}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';

      setState(() {
        profileImageUrl = data['profile_image'] ?? '';
      });

      originalData = {
        'name': nameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
      };
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final file = File(pickedFile.path);
      final fileName = path.basename(file.path);
      // final fileBytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.path) ?? 'image/*';

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final filePath = 'profile_images/${user.id}/$fileName';

      print('Before uploading...');

      // ✅ Upload the image to Supabase storage
      final uploadResponse = await supabase.storage
      .from('profile-images')
      .uploadBinary(
        filePath,
        await file.readAsBytes(),
        fileOptions: FileOptions(contentType: mimeType, upsert: true),
      );

      print('Upload response: ${uploadResponse}');

      // ✅ Get the public URL of the uploaded image
      final publicUrl = supabase.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      // ✅ Update Supabase user metadata
      final updateRes = await supabase.auth.updateUser(
        UserAttributes(
          data: {...?user.userMetadata, 'profile_picture': publicUrl},
        ),
      );

      if (updateRes.user == null) {
        throw Exception('Failed to update user metadata');
      }

      // ✅ Optionally update your backend
      await http.post(
        Uri.parse('http://192.168.58.129:5000/profile/update-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': user.id, 'profile_picture': publicUrl}),
      );

      // ✅ Update local state
      setState(() {
        profileImageUrl = publicUrl;
        isUploading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile image updated')));
    } catch (e) {
      print('Error: $e');
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload failed')));
    }
  }

  Future<void> _fetchContacts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.58.129:5000/contacts/${user.id}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        contacts = data;
      });
    }
  }

  Future<void> _deleteContact(BuildContext context, String contactId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
              'Are you sure you want to delete this contact?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      final response = await http.delete(
        Uri.parse('http://192.168.58.129:5000/contacts/delete/$contactId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted successfully')),
        );
        _fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete contact')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> updatedFields = {};

    if (nameController.text != originalData['name']) {
      updatedFields['name'] = nameController.text;
    }
    if (phoneController.text != originalData['phone']) {
      updatedFields['phone'] = phoneController.text;
    }
    if (emailController.text != originalData['email']) {
      updatedFields['email'] = emailController.text;
    }

    if (updatedFields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save')));
      return;
    }

    updatedFields['id'] = user.id;

    final response = await http.post(
      Uri.parse('http://192.168.58.129:5000/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved!')));
      setState(() {
        isEditing = false;
        originalData = {
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        };
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
    }
  }

  void _showAddContactPopup() {
    showDialog(
      context: context,
      builder: (_) => SaveContactPopupPage(onContactSaved: _fetchContacts),
    );
  }

  void _launchPhone(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open dialer')));
    }
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(contact['name'] ?? ''),
        subtitle: Text('${contact['relation']} - ${contact['phone']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _launchPhone(contact['phone']),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteContact(context, contact['id']),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileImageUrl!) // ✅ ImageProvider
                            : AssetImage('assets/profile.png'),
                    child:
                        profileImageUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                  ),
                  if (isUploading)
                    const Positioned.fill(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
              readOnly: !isEditing,
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
              readOnly: !isEditing,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              readOnly: !isEditing,
            ),
            const SizedBox(height: 30),
            if (!isEditing)
              ElevatedButton.icon(
                onPressed: () => setState(() => isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),
            if (isEditing)
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
              ),
            const Divider(height: 40),
            const Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            contacts.isEmpty
                ? const Text("No contacts saved yet!")
                : Column(
                  children: contacts.map((c) => _buildContactCard(c)).toList(),
                ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddContactPopup,
              icon: const Icon(Icons.add),
              label: const Text("Add Contact"),
            ),
          ],
        ),
      ),
    );
  }
}
