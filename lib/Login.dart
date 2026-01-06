import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin/admin_dashboard.dart';
import 'organizer.dart';
import 'UserHome.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Login Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Register Controllers
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthService authService = AuthService();

  String? errorMessage;
  bool switchValue = false;
  bool isLogin = true;
  bool isLoading = false;

  Future<void> _login() async {
    // Clear previous error
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      // Use AuthService for login
      final userCredential = await authService.signIn(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      // Check user role and navigate accordingly
      await _checkUserRoleAndNavigate(userCredential.user!);

    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getLoginErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getLoginErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      default:
        return 'Login failed. Please try again';
    }
  }

  Future<void> _register() async {
    // Validate all fields
    if (!_validateRegisterFields()) {
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      // Use AuthService to create account
      final userCredential = await authService.createAccount(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text,
      );

      // Create user profile in Firestore (if needed)
      await _createUserProfile(userCredential.user!);

      // Show success message and switch to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear all register fields
      _clearRegisterFields();

      // Switch to login mode
      setState(() {
        isLogin = true;
      });

    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getRegisterErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Registration failed. Please try again';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getRegisterErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Registration is currently disabled';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      default:
        return 'Registration failed. Please try again';
    }
  }

  bool _validateRegisterFields() {
    if (registerEmailController.text.isEmpty ||
        registerPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        phoneController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return false;
    }

    if (registerPasswordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(registerEmailController.text)) {
      setState(() {
        errorMessage = 'Please enter a valid email address';
      });
      return false;
    }

    return true;
  }

  Future<void> _createUserProfile(User user) async {
    // TODO: Implement Firestore user profile creation
    // You'll need to create a Firestore service or add Firestore here
    print('Creating profile for user: ${user.uid}');
    print('Email: ${user.email}');
    print('First Name: ${firstNameController.text}');
    print('Last Name: ${lastNameController.text}');
    print('DOB: ${dobController.text}');
    print('Phone: ${phoneController.text}');

    // storing additional user data:
     await FirebaseFirestore.instance
       .collection('users')
       .doc(user.uid)
       .set({
         'email': user.email,
         'firstName': firstNameController.text,
         'lastName': lastNameController.text,
         'dob': dobController.text,
         'phone': phoneController.text,
         'createdAt': FieldValue.serverTimestamp(),
    //     'role': 'user', // default role
       });
  }

  Future<void> _checkUserRoleAndNavigate(User user) async {
    final email = user.email ?? '';

    // Check for specific admin/organizer emails
    if (email == 'admin@berjaya.com') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else if (email == 'organizer@berjaya.com') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrganizerPage()),
      );
    } else {
      // Default user
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }

  }

  void _clearRegisterFields() {
    registerEmailController.clear();
    registerPasswordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    dobController.clear();
    phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    'MY ACCOUNT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login/Register Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Login Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogin = true;
                                errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: isLogin ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: isLogin ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Register Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogin = false;
                                errorMessage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: !isLogin ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: !isLogin ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Error Message Display
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                errorMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  if (errorMessage != null) const SizedBox(height: 15),

                  // Login Form Fields (only shown in login mode)
                  if (isLogin)
                    Column(
                      children: [
                        TextFormField(
                          controller: loginEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: loginPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),

                  // Register Form Fields (only shown in register mode)
                  if (!isLogin)
                    Column(
                      children: [
                        TextFormField(
                          controller: registerEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: registerPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: dobController,
                          onTap: () {
                            _selectDate(context);
                          },
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.local_phone),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),

                  //  forgot button in login only
                  if (isLogin)
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),

                  // Login Submit Button (only shown in login mode)
                  if (isLogin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.blue.shade200,
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Register Submit Button (only shown in register mode)
                  if (!isLogin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.green.shade200,
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'REGISTER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Divider with OR text
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //TODO: Social Login Buttons
                ],
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}