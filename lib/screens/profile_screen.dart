import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase instance & current user
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- CHANGE PASSWORD ---
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _currentUser!.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _formKey.currentState!.reset();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Error changing password: ${e.code}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FIXED LOGOUT FUNCTION ---
  Future<void> _signOut() async {
    // ✅ Get the navigator before the async call
    final navigator = Navigator.of(context);

    // ✅ Sign out user
    await _auth.signOut();

    // ✅ Pop all screens until we’re back at the first (AuthWrapper)
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- USER INFO ---
            Text(
              'Logged in as:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _currentUser?.email ?? 'Not logged in',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // --- CHANGE PASSWORD FORM ---
            Text(
              'Change Password',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration:
                    const InputDecoration(labelText: 'New Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- CHANGE PASSWORD BUTTON ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text('Change Password'),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // --- LOGOUT BUTTON ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _signOut,
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
