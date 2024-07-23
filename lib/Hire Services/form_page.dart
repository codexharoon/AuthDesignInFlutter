import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';

class FormPage extends StatefulWidget {
  final String selectedCategory;
  final String selectedCategoryOption;
  final String selectedCategorySubOption;
  final String selectedCategorySubOptionName;

  const FormPage({
    Key? key,
    required this.selectedCategory,
    required this.selectedCategoryOption,
    required this.selectedCategorySubOption,
    required this.selectedCategorySubOptionName,
  }) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  bool loading = false;

  @override
  void initState() {
    _whatsappController.text = currentUser?.phoneNumber ?? '';
    _emailController.text = currentUser?.email ?? '';
    super.initState();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        loading = true;
      });

      // Create a map of the data to store
      final orderData = {
        'whatsapp': _whatsappController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'selectedCategory': widget.selectedCategory,
        'selectedCategoryOption': widget.selectedCategoryOption,
        'selectedCategorySubOption': widget.selectedCategorySubOption,
        'selectedCategorySubOptionName': widget.selectedCategorySubOptionName,
        'userId': currentUser?.uid,
        'timestamp':
            FieldValue.serverTimestamp(), // Adds a server-side timestamp
      };

      try {
        // Store the data in Firestore
        await FirebaseFirestore.instance.collection('orders').add(orderData);

        // Show a success message or navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submitted successfully!')),
        );

        // combine services and sub services
        String services = widget.selectedCategory +
            ' - ' +
            widget.selectedCategoryOption +
            ' - ' +
            widget.selectedCategorySubOptionName;

        // send email

        sendEmailUsingEmailjs(
            name: currentUser?.displayName ?? 'user',
            email: _emailController.text,
            subject: services,
            message: _messageController.text,
            services: widget.selectedCategorySubOptionName);

        // Clear the form
        _whatsappController.clear();
        _emailController.clear();
        _messageController.clear();

        // // Navigate to the home page
        // Navigator.of(context).pop();
      } catch (e) {
        // Handle errors, e.g., show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting: $e')),
        );
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Page'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WhatsApp Number',
                  style: TextStyle(
                    color: Color(
                      0xFF11CEC4,
                    ),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    // labelText: 'Phone',
                    labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                    hintText: 'Enter your WhatsApp number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your WhatsApp number';
                    }
                    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                      return 'Please enter a valid WhatsApp number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Email Address',
                  style: TextStyle(
                    color: Color(
                      0xFF11CEC4,
                    ),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    // labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                    hintText: 'Enter your email address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Message',
                  style: TextStyle(
                    color: Color(
                      0xFF11CEC4,
                    ),
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    hintText: 'Enter your message',
                    prefixIcon: Icon(
                      Icons.message,
                      color: Color(0xFF11CEC4),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                loading
                    ? const CircularProgressIndicator(color: Color(0xFF11CEC4))
                    : Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _submitForm();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11CEC4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 110, vertical: 15),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
