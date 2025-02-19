import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scholarsync/themes/palette.dart';

import '../../widgets/app_bar.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  FeedbackFormState createState() => FeedbackFormState();
}

class FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedIndex;
  //
  String? _selectedFeedback;
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight), // Set the preferred height
        child: CustomAppBar(
          title: 'Academic Staff',
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          titleCenter: true,
          leftIcon: true,
          onPressedListButton: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 370,
                height: 653,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).dialogBackgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Help us serve you better',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'How would you rate your overall experience with ScholarSync?*',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          feedbackColorBox(
                              'Terrible', Icons.sentiment_very_dissatisfied, 0),
                          const SizedBox(width: 2),
                          feedbackColorBox(
                              'Bad', Icons.sentiment_dissatisfied, 1),
                          const SizedBox(width: 2),
                          feedbackColorBox('Okay', Icons.sentiment_neutral, 2),
                          const SizedBox(width: 2),
                          feedbackColorBox(
                              'Good', Icons.sentiment_satisfied, 3),
                          const SizedBox(width: 2),
                          feedbackColorBox(
                              'Amazing', Icons.sentiment_very_satisfied, 4),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const Text(
                              'What specific features do you like most about the app?',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _controller1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your rating';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'What improvements or new features would you like to see in future updates?',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _controller2,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your suggestions';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Any other feedback or suggestions?',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                )),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _controller3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your feedback';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: SizedBox(
                            width: 108.68,
                            height: 31.91,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState != null &&
                                    _formKey.currentState!.validate() &&
                                    _selectedFeedback != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Process Sucessful')));
                                  FirebaseFirestore.instance
                                      .collection('feedback')
                                      .add({
                                    'emotion': _selectedFeedback,
                                    'text1': _controller1.text,
                                    'text2': _controller2.text,
                                    'text3': _controller3.text
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please select emotion of your mind!')));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      CommonColors.secondaryGreenColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: const Text(
                                'Submit',
                                style:
                                    TextStyle(color: CommonColors.whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget feedbackColorBox(String text, IconData icon, int index) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
          _selectedFeedback = text;
        });
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: index == _selectedIndex
              ? CommonColors.secondaryGreenColor
              : Colors.white,
          fixedSize: const Size(
            62,
            70,
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Icon(
            icon,
            color: index == _selectedIndex
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.grey,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 8,
              color: index == _selectedIndex ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
