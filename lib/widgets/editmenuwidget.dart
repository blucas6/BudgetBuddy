import 'package:budgetbuddy/components/tags.dart';
import 'package:flutter/material.dart';

class EditMenuWidget extends StatefulWidget {
  // This widget lets the user edit a transaction

  const EditMenuWidget({super.key});

  @override
  State<EditMenuWidget> createState() => EditMenuWidgetState();
}

class EditMenuWidgetState extends State<EditMenuWidget> {
  String? _selectedTag;   // keep track of which tag is being selected
  List<String> possibleTags = [
    Tags().HIDDEN,
    Tags().INCOME,
    Tags().RENT,
    Tags().SAVINGS
  ];  // possible tags

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Add a tag"),
        content: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tag Transaction: "),
              DropdownButton(
                value: _selectedTag,
                hint: Text('Select a tag'),
                items: possibleTags.map((String tag) {
                  return DropdownMenuItem(value: tag, child: Text(tag));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                      if (newValue != null) {
                        _selectedTag = newValue;
                        // return tag picked by user
                        Navigator.of(context).pop(newValue);
                      }
                    }
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    // return special string to delete all tags from transaction
                    Navigator.of(context).pop('_delete_');
                  });
                },
                icon: const Icon(Icons.delete_outline)
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'))
          ],
      );
  }

}