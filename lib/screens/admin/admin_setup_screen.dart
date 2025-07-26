// lib/screens/admin/admin_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/admin_model.dart';

class AdminSetupScreen extends StatefulWidget {
  @override
  _AdminSetupScreenState createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secretKeyController = TextEditingController();
  
  bool _isLoading = false;
  
  // Secret key to prevent unauthorized admin creation (change this!)
  final String _adminSecretKey = "FARMER_FRIENDS_ADMIN_2024";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Setup'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text(
                          'Development Only',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This screen is for development purposes only. Remove before production deployment.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Admin Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      controller: _secretKeyController,
                      label: 'Admin Secret Key',
                      hint: 'Enter admin secret key',
                      prefixIcon: Icons.key,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter secret key';
                        }
                        if (value != _adminSecretKey) {
                          return 'Invalid secret key';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Admin Name',
                      hint: 'Enter admin full name',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter admin name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Admin Email',
                      hint: 'Enter admin email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter admin email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Admin Password',
                      hint: 'Enter admin password',
                      obscureText: true,
                      prefixIcon: Icons.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    CustomButton(
                      text: 'Create Admin Account',
                      isLoading: _isLoading,
                      onPressed: _createAdminAccount,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildExistingAdmins(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingAdmins() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Existing Admins',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('admins').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text(
                  'No admin accounts found',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }
              
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        data['name']?.substring(0, 1).toUpperCase() ?? 'A',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(data['name'] ?? 'Unknown'),
                    subtitle: Text(data['email'] ?? 'No email'),
                    trailing: Chip(
                      label: Text(
                        data['role'] ?? 'admin',
                        style: TextStyle(fontSize: 10),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createAdminAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Auth
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.user != null) {
        // Create admin record in Firestore
        final admin = AdminModel(
          id: result.user!.uid,
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          role: 'admin',
          permissions: [
            'manage_products',
            'manage_orders',
            'view_analytics',
          ],
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('admins')
            .doc(result.user!.uid)
            .set(admin.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin account created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _secretKeyController.clear();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create admin: ${e.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}