// lib/services/admin_setup_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

class AdminSetupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Call this method once to create initial admin
  static Future<bool> createInitialAdmin() async {
    try {
      // Check if any admin already exists
      QuerySnapshot existingAdmins = await _firestore.collection('admins').limit(1).get();
      if (existingAdmins.docs.isNotEmpty) {
        print('Admin already exists');
        return false;
      }

      // Create admin user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: 'admin@farmerfriendsghana.com',
        password: 'FarmerFriends2024!', // Change this password!
      );

      if (result.user != null) {
        // Create admin record in Firestore
        final admin = AdminModel(
          id: result.user!.uid,
          email: 'admin@farmerfriendsghana.com',
          name: 'Super Admin',
          role: 'super_admin',
          permissions: [
            'manage_products',
            'manage_orders',
            'manage_users',
            'view_analytics',
            'manage_admins',
          ],
          createdAt: DateTime.now(),
        );

        await _firestore.collection('admins').doc(result.user!.uid).set(admin.toMap());
        
        print('Initial admin created successfully');
        print('Email: admin@farmerfriendsghana.com');
        print('Password: FarmerFriends2024!');
        
        return true;
      }
    } catch (e) {
      print('Error creating initial admin: $e');
      return false;
    }
    return false;
  }

  // Create additional admin accounts
  static Future<bool> createAdmin({
    required String email,
    required String password,
    required String name,
    String role = 'admin',
    List<String> permissions = const [
      'manage_products',
      'manage_orders',
      'view_analytics',
    ],
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final admin = AdminModel(
          id: result.user!.uid,
          email: email,
          name: name,
          role: role,
          permissions: permissions,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('admins').doc(result.user!.uid).set(admin.toMap());
        return true;
      }
    } catch (e) {
      print('Error creating admin: $e');
      return false;
    }
    return false;
  }

  // Delete admin account
  static Future<bool> deleteAdmin(String adminId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('admins').doc(adminId).delete();
      
      // Note: We cannot delete users from Firebase Auth using client SDK
      // This requires Firebase Admin SDK on the server side
      
      return true;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    }
  }

  // Update admin role/permissions
  static Future<bool> updateAdmin({
    required String adminId,
    String? name,
    String? role,
    List<String>? permissions,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      
      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (permissions != null) updates['permissions'] = permissions;
      
      if (updates.isNotEmpty) {
        await _firestore.collection('admins').doc(adminId).update(updates);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating admin: $e');
      return false;
    }
  }
}