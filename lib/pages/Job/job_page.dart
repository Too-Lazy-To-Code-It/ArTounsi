import 'package:Artounsi/entities/Job/project.dart';
import 'package:Artounsi/pages/Job/project_creation_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class JobPage extends StatefulWidget {
  const JobPage({Key? key}) : super(key: key);

  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  late List<Project> projectList;

  @override
  void initState() {
    super.initState();
    projectList = [
      Project(
        id: generateRandomId(),
        title: "Sunset Beach",
        description: "A beautiful oil painting of a sunset at the beach.",
        mainImagePath: "assets/images/logo.png",
        additionalImagePaths: [
          "assets/images/sunset_beach_1.jpg",
          "assets/images/sunset_beach_2.jpg",
        ],
        projectLink: "https://myportfolio.com/sunset-beach",
      ),
      Project(
        id: generateRandomId(),
        title: "Urban Sketch",
        description: "A series of urban sketches capturing city life.",
        mainImagePath: "assets/images/logo.png",
        additionalImagePaths: [
          "assets/images/urban_sketch_1.jpg",
          "assets/images/urban_sketch_2.jpg",
          "assets/images/urban_sketch_3.jpg",
        ],
        projectLink: "https://myportfolio.com/urban-sketch",
      ),
      Project(
        id: generateRandomId(),
        title: "Abstract Emotions",
        description: "An abstract painting series exploring human emotions.",
        mainImagePath: "assets/images/logo.png",
        additionalImagePaths: [
          "assets/images/abstract_emotions_1.jpg",
          "assets/images/abstract_emotions_2.jpg",
        ],
        projectLink: "https://myportfolio.com/abstract-emotions",
      ),
      Project(
        id: generateRandomId(),
        title: "Nature Photography",
        description: "A collection of nature photographs from various national parks.",
        mainImagePath: "assets/images/logo.png",
        additionalImagePaths: [
          "assets/images/nature_photography_1.jpg",
          "assets/images/nature_photography_2.jpg",
          "assets/images/nature_photography_3.jpg",
          "assets/images/nature_photography_4.jpg",
        ],
        projectLink: "https://myportfolio.com/nature-photography",
      ),
      Project(
        id: generateRandomId(),
        title: "Digital Art: Futuristic Cities",
        description: "A series of digital artworks depicting futuristic cityscapes.",
        mainImagePath: "assets/images/logo.png",
        additionalImagePaths: [
          "assets/images/futuristic_cities_1.jpg",
          "assets/images/futuristic_cities_2.jpg",
        ],
        projectLink: "https://myportfolio.com/futuristic-cities",
      ),
    ];
  }

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
        itemCount: projectList.length,
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
                      child: Image.asset(
                        projectList[index].mainImagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(projectList[index].title),
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
        },
        child: Icon(Icons.add),
      ),
    );
  }
}