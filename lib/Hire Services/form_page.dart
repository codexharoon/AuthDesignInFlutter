import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/pay_now_page.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class FormPage extends StatefulWidget {
  final String selectedCategory;
  final String selectedCategoryOption;
  final String selectedCategorySubOption;
  final String selectedCategorySubOptionName;
  final double price;

  const FormPage({
    Key? key,
    required this.selectedCategory,
    required this.selectedCategoryOption,
    required this.selectedCategorySubOption,
    required this.selectedCategorySubOptionName,
    required this.price,
  }) : super(key: key);

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  bool loading = false;

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String? fileUrl;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    if (pickedFile == null) return;

    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download Link: $urlDownload');

    setState(() {
      fileUrl = urlDownload;
      uploadTask = null;
    });
  }

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
        'name': _nameController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'selectedCategory': widget.selectedCategory,
        'selectedCategoryOption': widget.selectedCategoryOption,
        'selectedCategorySubOption': widget.selectedCategorySubOption,
        'selectedCategorySubOptionName': widget.selectedCategorySubOptionName,
        'userId': currentUser?.uid,
        'status': 'in progress',
        'fileUrl': fileUrl ?? '',
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
        String services =
            '${widget.selectedCategory} - ${widget.selectedCategoryOption} - ${widget.selectedCategorySubOption} - ${widget.selectedCategorySubOptionName}';

        // send email

        sendEmailUsingEmailjs(
            name: _nameController.text,
            email: _emailController.text,
            subject: services,
            message: _messageController.text,
            services: widget.selectedCategorySubOptionName);

        // Clear the form
        _nameController.clear();
        _whatsappController.clear();
        _messageController.clear();

        // Navigate to the pay now page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PayNowPage(
              heading: widget.selectedCategory,
              title: widget.selectedCategoryOption,
              subTitle: widget.selectedCategorySubOption,
              option: widget.selectedCategorySubOptionName,
              totalPrice: widget.price,
            ),
          ),
        );
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
      body: SingleChildScrollView(
        child: Column(children: [
          Text(
            '${widget.selectedCategory} > ${widget.selectedCategoryOption} > ${widget.selectedCategorySubOption} > ${widget.selectedCategorySubOptionName}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        color: Color(
                          0xFF11CEC4,
                        ),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF11CEC4))),
                        // labelText: 'Name',
                        labelStyle: TextStyle(color: Color(0xFF11CEC4)),
                        hintText: 'Enter your name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
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
                    ElevatedButton(
                      onPressed: selectFile,
                      child: const Text(
                        'Select File',
                      ),
                    ),
                    if (pickedFile != null)
                      Container(
                        child:
                            // pickedFile!.extension == 'jpg' ||
                            //         pickedFile!.extension == 'jpeg' ||
                            //         pickedFile!.extension == 'png'
                            //     ? Container(
                            //         child: Image.file(
                            //           File(pickedFile!.path!),
                            //           width: 100,
                            //           height: 100,
                            //           fit: BoxFit.cover,
                            //         ),
                            //       )
                            //     :
                            ListTile(
                          title: Text(pickedFile!.name),
                          subtitle: Text(
                              '${(pickedFile!.size / 1024).toStringAsFixed(2)} KB'),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: uploadFile,
                      child: const Text(
                        'Upload File',
                      ),
                    ),
                    buildProgress(),
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
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF11CEC4)),
                          )
                        : Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  // _formKey.currentState?.save();
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
        ]),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  Center(
                    child: Text(
                      '$percentage %',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      );
}
