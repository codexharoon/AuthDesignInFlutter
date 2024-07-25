import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/pay_now_page.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final TextEditingController controller = TextEditingController();
  String initialCountry = 'PK';
  PhoneNumber number = PhoneNumber(isoCode: 'PK');

  final _nameController = TextEditingController();
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
        'name': _nameController.text.trim(),
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
              totalPrice: 100,
              services: widget.selectedCategorySubOptionName,
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

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'PK');

    setState(() {
      this.number = number;
    });
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    super.dispose();
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
                    // InternationalPhoneNumberInput(
                    //   onInputChanged: (PhoneNumber number) {
                    //     print('Phone number changed: ${number.phoneNumber}');
                    //   },
                    //   onInputValidated: (bool value) {
                    //     print('input validate: $value');
                    //   },
                    //   selectorConfig: const SelectorConfig(
                    //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    //     useBottomSheetSafeArea: true,
                    //   ),
                    //   ignoreBlank: false,
                    //   // autoValidateMode: AutovalidateMode.disabled,
                    //   selectorTextStyle:
                    //       const TextStyle(color: Color(0xFF11CEC4)),
                    //   initialValue: number,
                    //   textFieldController: _whatsappController,
                    //   formatInput: true,
                    //   keyboardType: const TextInputType.numberWithOptions(
                    //       signed: true, decimal: true),
                    //   inputBorder: const OutlineInputBorder(
                    //     borderSide: BorderSide(color: Color(0xFF11CEC4)),
                    //   ),
                    //   inputDecoration: const InputDecoration(
                    //     enabledBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    //     focusedBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Color(0xFF11CEC4))),
                    //     hintText: 'Enter your WhatsApp number',
                    //   ),
                    //   onSaved: (PhoneNumber number) {
                    //     print('On Saved: $number');
                    //   },
                    // ),
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
}
