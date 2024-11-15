

import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  final Datadistributer datadistributer;
  const ProfileView({super.key, required this.datadistributer});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  Map<String, double> profile = {
    "totalspending": 0,
    "totalincome": 0,
    "totalassets": 0,
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    debugPrint("Reloading profile widget");
    profile = await widget.datadistributer.loadProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.lightBlueAccent,
          width: 3
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Profile Summary',
            style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),),
          Text('Total Spending: ${profile['totalspending']!.toStringAsFixed(2)}'),
          Text('Total Income: ${profile['totalincome']!.toStringAsFixed(2)}'),
          Text('Net Worth: ${profile['totalassets']!.toStringAsFixed(2)}'),
        ]
      ),
    );
  }
}