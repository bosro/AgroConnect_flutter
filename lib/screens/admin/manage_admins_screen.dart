// lib/screens/admin/manage_admins_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/admin_notification_service.dart';

class ManageAdminsScreen extends StatefulWidget {
  @override
  _ManageAdminsScreenState createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'admin';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Admins'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddAdminForm(),
            SizedBox(height: 20),
            Expanded(child: _buildAdminsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAdminForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Admin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              label: 'Admin Name',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
              ],
              onChanged: (value) => setState(() => _selectedRole = value!),
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Create Admin',
              isLoading: _isLoading,
              onPressed: _createAdmin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('admins').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No admins found'));
        }
        
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(data['name']?.substring(0, 1).toUpperCase() ?? 'A'),
                ),
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text(data['email'] ?? 'No email'),
                trailing: Chip(
                  label: Text(data['role'] ?? 'admin'),
                  backgroundColor: data['role'] == 'super_admin' 
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await AdminSetupService.createAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admin created successfully'), backgroundColor: AppColors.success),
        );
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create admin'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}