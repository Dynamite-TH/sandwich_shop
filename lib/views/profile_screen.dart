import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/repositories/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Note: profile data is stored in ProfileProvider for the session

  // Editing controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final FocusNode _nameFocus = FocusNode();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers from provider (read once)
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.name);
    _emailController = TextEditingController(text: provider.email);
    _phoneController = TextEditingController(text: provider.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _enterEditMode() {
    setState(() {
      _isEditing = true;
    });
    // focus after a short delay to ensure widgets are rendered
    Future.delayed(Duration(milliseconds: 100), () {
      _nameFocus.requestFocus();
    });
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.setProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  void _cancelEdit() {
    setState(() {
      // reset controllers to provider values
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      _nameController.text = provider.name;
      _emailController.text = provider.email;
      _phoneController.text = provider.phone;
      _isEditing = false;
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final email = value.trim();
    final emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final phoneRegex = RegExp(r'^[0-9+\-\s()]*$');
    if (!phoneRegex.hasMatch(value)) return 'Invalid phone number';
    return null;
  }

  Widget _buildViewMode() {
    final provider = Provider.of<ProfileProvider>(context);
    final bool empty = provider.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (empty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Complete your profile', style: normalText),
          )
        else ...[
          ListTile(
            title: Text(
              provider.name.isEmpty ? 'Name' : provider.name,
              style: heading2,
            ),
            subtitle: const Text('Name'),
          ),
          const Divider(),
          ListTile(
            title: Text(
              provider.email.isEmpty ? 'Email' : provider.email,
              style: heading2,
            ),
            subtitle: const Text('Email'),
          ),
          const Divider(),
          ListTile(
            title: Text(
              provider.phone.isEmpty ? 'Phone' : provider.phone,
              style: heading2,
            ),
            subtitle: const Text('Phone'),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _enterEditMode, child: const Text('Edit')),
      ],
    );
  }

  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: _validateName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEdit,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_isEditing ? _buildEditMode() : _buildViewMode()],
        ),
      ),
    );
  }
}
