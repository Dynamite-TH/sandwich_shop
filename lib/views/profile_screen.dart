import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Saved in-memory values for the session
  String _savedName = '';
  String _savedEmail = '';
  String _savedPhone = '';

  // Editing controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final FocusNode _nameFocus = FocusNode();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _savedName);
    _emailController = TextEditingController(text: _savedEmail);
    _phoneController = TextEditingController(text: _savedPhone);
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

    setState(() {
      _savedName = _nameController.text.trim();
      _savedEmail = _emailController.text.trim();
      _savedPhone = _phoneController.text.trim();
      _isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _savedName;
      _emailController.text = _savedEmail;
      _phoneController.text = _savedPhone;
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
    final bool empty =
        _savedName.isEmpty && _savedEmail.isEmpty && _savedPhone.isEmpty;
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
              _savedName.isEmpty ? 'Name' : _savedName,
              style: heading2,
            ),
            subtitle: const Text('Name'),
          ),
          const Divider(),
          ListTile(
            title: Text(
              _savedEmail.isEmpty ? 'Email' : _savedEmail,
              style: heading2,
            ),
            subtitle: const Text('Email'),
          ),
          const Divider(),
          ListTile(
            title: Text(
              _savedPhone.isEmpty ? 'Phone' : _savedPhone,
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
