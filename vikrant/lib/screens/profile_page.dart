import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/mobiledata.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: savedName ?? '');
    _ageController = TextEditingController(text: savedAge?.toString() ?? '');
    if (savedProfileImage != null && savedProfileImage!.isNotEmpty) {
      _imageFile = File(savedProfileImage!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        saveProfileInfo(
          _nameController.text.trim(),
          int.tryParse(_ageController.text.trim()) ?? 0,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await saveProfileImage(pickedFile.path);
    }
  }

  Widget _buildCard({required String label, required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            blurRadius: 12,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontFamily: 'Nico Moji'),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.white),
            onPressed: _toggleEdit,
            tooltip: isEditing ? 'Save' : 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Photo with edit
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.white12,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : const AssetImage('assets/images/racing_avatar.png') as ImageProvider,
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name
            _buildCard(
              label: 'Name',
              content: isEditing
                  ? TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Enter Name',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
              )
                  : Text(
                _nameController.text.isNotEmpty ? _nameController.text : '',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // Email
            _buildCard(
              label: 'Email',
              content: Text(
                savedEmail ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            // Age
            _buildCard(
              label: 'Age',
              content: isEditing
                  ? TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Enter Age',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
              )
                  : Text(
                savedAge != null ? savedAge.toString() : '',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            // Bike Number
            _buildCard(
              label: 'Bike No',
              content: Text(
                savedBikeNumber ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
