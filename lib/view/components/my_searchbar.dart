import 'package:flutter/material.dart';

/*
  사용 방법

  Padding(
    padding: const EdgeInsets.all(16.0),
    child: SearchWidget(items: items)
  ),

*/

class MySearchDelegate extends SearchDelegate<String> {
  final List<String> items;

  MySearchDelegate(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((item) => item.contains(query)).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items.where((item) => item.contains(query)).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}

class SearchWidget extends StatelessWidget {
  final List<String> items;

  const SearchWidget({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () {
        showSearch(
          context: context,
          delegate: MySearchDelegate(items),
        );
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        prefixIcon: Icon(Icons.search),
        labelText: '메뉴, 가게 이름 검색',
      ),
    );
  }
}

final items = [
  'Apple',
  'Banana',
  'Cherry',
  'Date',
  'Elderberry',
  'Fig',
  'Grape',
  'Honeydew',
];