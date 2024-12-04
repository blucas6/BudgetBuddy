

import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  // This object displays to the user data associated with the entire profile

  final Datadistributer datadistributer;  // access to pipeline

  const ProfileView({super.key, required this.datadistributer});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  // map of data associated with the profile
  Map<String, double> profile = {
    "totalspending": 0,
    "totalincome": 0,
    "totalassets": 0,
    "totalsavings": 0
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // load new data
  void loadData() async {
    debugPrint("Reloading profile widget");
    profile = await widget.datadistributer.loadProfile();
    // print(profile);
    setState(() {});
  }

  Text getDisplayText(String label, double value) {
    String neg = '';
    String valuetext = '';
    if (value < 0) {
      neg = '-';
      value = value*-1;
    }
    valuetext = value.toStringAsFixed(2);
    return Text('$label: \t$neg\$$valuetext',
    style: TextStyle(fontSize: 16),);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: EdgeInsets.only(top:10, bottom: 20, right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Profile Summary',
              style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),),
            SizedBox(height: 10),
            getDisplayText('Total Spending', profile['totalspending']!),
            getDisplayText('Total Income', profile['totalincome']!),
            getDisplayText('Total Savings', profile['totalsavings']!),
            getDisplayText('Net Worth', profile['totalassets']!),
          ]
        ),
      ),
    );
  }
}