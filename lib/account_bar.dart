import 'package:flutter/material.dart';

class AccountBar extends StatefulWidget {
  const AccountBar({super.key});
  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  void addNewAccount() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Text(
          'Accounts',
        ),
      ],
    );
  }
}
