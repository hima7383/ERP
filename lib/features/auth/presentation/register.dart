import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gap/gap.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    try {
      final companyName = _companyNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final address = _addressController.text.trim();
      final domain = _domainController.text.trim();

      if (companyName.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      final uri = Uri.parse(
        'https://erpdevelopment.runasp.net/Api/main/company/create',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['CompanyName'] = companyName
        ..fields['CompanyEmail'] = email
        ..fields['Password'] = password
        ..fields['CompanyAddress'] = address
        ..fields['Domain'] = domain;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 && responseBody['succeeded'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please login')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  bool _validatePassword(String value) {
    return value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[0-9]')) &&
        value.contains(RegExp(r'[^a-zA-Z0-9]'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text('Company Registration',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
          bottom: 20,
          left: size.width * 0.08,
          right: size.width * 0.08,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "START MANAGING YOUR BUSINESS",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(30),
              _buildSectionTitle("Company Information"),
              TextFormField(
                controller: _companyNameController,
                decoration:
                    _buildInputDecoration("Company Name *", Icons.business),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Company name is required' : null,
              ),
              Gap(20),
              _buildSectionTitle("Contact Details"),
              TextFormField(
                controller: _emailController,
                decoration:
                    _buildInputDecoration("Company Email *", Icons.email),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              Gap(20),
              _buildSectionTitle("Security"),
              TextFormField(
                controller: _passwordController,
                decoration: _buildInputDecoration(
                  "Password *",
                  Icons.lock,
                  helperText: 'Must include: uppercase, number, special char',
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Password is required';
                  if (!_validatePassword(value!)) {
                    return 'Password must include uppercase, number, and special char';
                  }
                  return null;
                },
              ),
              Gap(20),
              _buildSectionTitle("Additional Information"),
              TextFormField(
                controller: _addressController,
                decoration:
                    _buildInputDecoration("Company Address", Icons.location_on),
                style: const TextStyle(color: Colors.white),
              ),
              Gap(20),
              TextFormField(
                controller: _domainController,
                decoration:
                    _buildInputDecoration("Domain (Optional)", Icons.web),
                style: const TextStyle(color: Colors.white),
              ),
              Gap(30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _register(context),
                child: const Text(
                  "GET STARTED",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon,
      {String? helperText}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[900], // Dark input field
      labelStyle: const TextStyle(color: Colors.white70),
      helperText: helperText,
      helperStyle: const TextStyle(color: Colors.white54),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
    );
  }
}
