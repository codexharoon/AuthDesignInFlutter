// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color_extension.dart';
import 'invoice_page.dart';
// import 'round_button.dart';
import 'dart:math';

class PayNowPage extends StatefulWidget {
  final double totalPrice;

  const PayNowPage({Key? key, required this.totalPrice}) : super(key: key);

  @override
  State<PayNowPage> createState() => _PayNowPageState();
}

class _PayNowPageState extends State<PayNowPage> {
  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/images/cash.png"},
    // {"name": "**** **** **** 2187", "icon": "assets/images/visa_icon.png"},
    // {"name": "test@gmail.com", "icon": "assets/images/paypal.png"},
  ];

  int selectMethod = -1;
  late String deliveryAddress = "";
  String deliveryPhone = "";
  String deliveryName = "";
  String deliveryEmail = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // _navigateToChangeAddressView();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');

      if (uid != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('UserData')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            deliveryAddress = userDoc.get('address') ?? "No address available";
            deliveryEmail = userDoc.get("email") ?? "No email available";
            deliveryName = userDoc.get("fullName") ?? "No name available";
            deliveryPhone = userDoc.get("contact") ?? "No contact available";
          });
        } else {
          setState(() {
            deliveryAddress = "No address available";
            deliveryEmail = "No email available";
            deliveryName = "No name available";
            deliveryPhone = "No contact available";
          });
        }
      } else {
        setState(() {
          deliveryAddress = "User ID not found";
          deliveryEmail = "User ID not found";
          deliveryName = "User ID not found";
          deliveryPhone = "User ID not found";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        deliveryAddress = "Error loading address";
        deliveryEmail = "Error loading email";
        deliveryName = "Error loading name";
        deliveryPhone = "Error loading contact";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deliveryCost = 2; // Example delivery cost
    double discount = 4; // Example discount
    double subTotal = widget.totalPrice;
    double total = subTotal + deliveryCost - discount;

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        "assets/images/btn_back.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Selected Services",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Service Name",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Service Name",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment method",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: TColor.primary),
                          label: Text(
                            "Add Card",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // ListView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   padding: EdgeInsets.zero,
                    //   shrinkWrap: true,
                    //   itemCount: paymentArr.length,
                    //   itemBuilder: (context, index) {
                    //     var pObj = paymentArr[index] as Map? ?? {};
                    //     return Container(
                    //       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    //       padding: const EdgeInsets.symmetric(
                    //         vertical: 8.0,
                    //         horizontal: 15.0,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: TColor.textfield,
                    //         borderRadius: BorderRadius.circular(5),
                    //         border: Border.all(
                    //           color: TColor.secondaryText.withOpacity(0.2),
                    //         ),
                    //       ),
                    //       child: Row(
                    //         children: [
                    //           Image.asset(
                    //             pObj["icon"].toString(),
                    //             width: 50,
                    //             height: 20,
                    //             fit: BoxFit.contain,
                    //           ),
                    //           Expanded(
                    //             child: Text(
                    //               pObj["name"],
                    //               style: TextStyle(
                    //                 color: TColor.primaryText,
                    //                 fontSize: 12,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //           InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 selectMethod = index;
                    //               });
                    //             },
                    //             child: Icon(
                    //               selectMethod == index
                    //                   ? Icons.radio_button_on
                    //                   : Icons.radio_button_off,
                    //               color: TColor.primary,
                    //               size: 15,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\$${widget.totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fee Tax (example)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\$2",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "-\$4",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Divider(
                      color: TColor.secondaryText.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "\$${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoicePage(
                                deliveryName: 'haroon',
                                deliveryEmail: 'example@mail.com',
                                deliveryAddress: 'xyz add',
                                deliveryCost: deliveryCost.toString(),
                                deliveryPhone: deliveryPhone),
                          ),
                        );
                      },
                      child: const Text("Generate Receipt"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11CEC4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 110, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text(
                        "Pay Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
