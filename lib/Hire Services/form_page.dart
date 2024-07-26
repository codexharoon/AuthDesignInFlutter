import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/pay_now_page.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';

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

  List<PlatformFile> pickedFiles = [];
  List<UploadTask?> uploadTasks = [];
  List<String> fileUrls = [];

  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

  Future selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result == null) return;

    setState(() {
      for (var file in result.files) {
        if (!pickedFiles
            .any((existingFile) => existingFile.name == file.name)) {
          pickedFiles.add(file);
        }
      }
    });
  }

  Future uploadFiles() async {
    if (pickedFiles.isEmpty) return;

    List<String> urls = [];

    for (var file in pickedFiles) {
      final path = 'files/${file.name}';
      final fileToUpload = File(file.path!);
      final ref = FirebaseStorage.instance.ref().child(path);

      final uploadTask = ref.putFile(fileToUpload);

      setState(() {
        uploadTasks.add(uploadTask);
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      print('Download Link: $urlDownload');
      urls.add(urlDownload);
    }

    setState(() {
      fileUrls = urls;
      uploadTasks = [];
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
        'fileUrl': fileUrls,
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
                      onPressed: selectFiles,
                      child: const Text(
                        'Select File',
                      ),
                    ),
                    if (pickedFiles.isNotEmpty)
                      Column(
                        children: pickedFiles.map((file) {
                          final fileExtension = file.extension?.toLowerCase();
                          final isImage =
                              imageExtensions.contains(fileExtension);

                          return ListTile(
                            leading: isImage
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(File(file.path!)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.insert_drive_file,
                                    size: 50, color: Colors.grey),
                            title: Text(file.name),
                            subtitle: Text(
                                '${(file.size / 1024).toStringAsFixed(2)} KB'),
                          );
                        }).toList(),
                      ),
                    ElevatedButton(
                      onPressed: uploadFiles,
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

  Widget buildProgress() => Column(
        children: uploadTasks.map((task) {
          return StreamBuilder<TaskSnapshot>(
            stream: task?.snapshotEvents,
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
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
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
        }).toList(),
      );
}
