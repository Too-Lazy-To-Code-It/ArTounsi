import 'package:Artounsi/pages/Job/project_creation_page.dart';
import 'package:flutter/material.dart';

class JobPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('My Portfolio'),
      ),*/
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 10, // Replace with actual project count
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to project detail page
            },
            child: Card(
              child: Padding(
            padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      'https://placeholder.com/150', // Replace with actual image
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Project ${index + 1}'),
                  ),
                ],
              ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProjectCreationPage()),
          );
          // Navigate to project creation page
        },
        child: Icon(Icons.add),
      ),
    );
  }
}