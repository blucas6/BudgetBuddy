import 'package:flutter/material.dart';

class NewAccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()),
        );
      },
      child: Text('Set up a New Account'),
    );
  }
}

class CreateAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Account')),
      body: Center(
        child: Text('Account creation form goes here.'),
      ),
    );
  }
}

