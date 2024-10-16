import 'package:flutter/material.dart';

class AccountBar extends StatefulWidget {
  const AccountBar({super.key});

  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  List<String> accountList = [];

  void addNewAccount() {
    setState(() {
      accountList.add('tmpaccount');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          'Accounts',
        ),
        Column(
            children: accountList
                .map(
                  (text) => Text(text),
                )
                .toList()),
        TextButton(
          onPressed: addNewAccount,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
                const Color.fromARGB(255, 12, 183, 226)),
          ),
          child: const Text('+'),
        ),
      ],
    );
  }
}
