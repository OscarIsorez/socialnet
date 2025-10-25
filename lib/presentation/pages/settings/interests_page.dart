import 'package:flutter/material.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Map<String, List<String>> _interestCategories = const {
    'Music': ['Rock', 'Rap', 'Jazz', 'Classical'],
    'Sports': ['Football', 'Basketball', 'Running', 'Cycling'],
    'Arts': ['Painting', 'Photography', 'Theatre', 'Cinema'],
  };

  final Set<String> _selectedInterests = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select interests'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedInterests),
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        children: _interestCategories.entries
            .map((entry) => _buildCategory(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  Widget _buildCategory(String category, List<String> interests) {
    return ExpansionTile(
      title: Text(category),
      children: interests
          .map(
            (interest) => CheckboxListTile(
              title: Text(interest),
              value: _selectedInterests.contains(interest),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }
}
