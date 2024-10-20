import 'package:Artounsi/entities/Job/project.dart';
import 'package:Artounsi/pages/Job/project_creation_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
class JobPage extends StatelessWidget {



// Create a list of Project instances
  List<Project> projectList = [
    Project(
      id: "1",
      title: "Sunset Beach",
      description: "A beautiful oil painting of a sunset at the beach.",
      mainImagePath: "assets/images/sunset_beach_main.jpg",
      additionalImagePaths: [
        "assets/images/sunset_beach_1.jpg",
        "assets/images/sunset_beach_2.jpg",
      ],
      projectLink: "https://myportfolio.com/sunset-beach",
    ),
    Project(
      id: "2",
      title: "Urban Sketch",
      description: "A series of urban sketches capturing city life.",
      mainImagePath: "assets/images/urban_sketch_main.jpg",
      additionalImagePaths: [
        "assets/images/urban_sketch_1.jpg",
        "assets/images/urban_sketch_2.jpg",
        "assets/images/urban_sketch_3.jpg",
      ],
      projectLink: "https://myportfolio.com/urban-sketch",
    ),
    Project(
      id: "3",
      title: "Abstract Emotions",
      description: "An abstract painting series exploring human emotions.",
      mainImagePath: "assets/images/abstract_emotions_main.jpg",
      additionalImagePaths: [
        "assets/images/abstract_emotions_1.jpg",
        "assets/images/abstract_emotions_2.jpg",
      ],
      projectLink: "https://myportfolio.com/abstract-emotions",
    ),
    Project(
      id: "4",
      title: "Nature Photography",
      description: "A collection of nature photographs from various national parks.",
      mainImagePath: "assets/images/nature_photography_main.jpg",
      additionalImagePaths: [
        "assets/images/nature_photography_1.jpg",
        "assets/images/nature_photography_2.jpg",
        "assets/images/nature_photography_3.jpg",
        "assets/images/nature_photography_4.jpg",
      ],
      projectLink: "https://myportfolio.com/nature-photography",
    ),
    Project(
      id: "5",
      title: "Digital Art: Futuristic Cities",
      description: "A series of digital artworks depicting futuristic cityscapes.",
      mainImagePath: "assets/images/futuristic_cities_main.jpg",
      additionalImagePaths: [
        "assets/images/futuristic_cities_1.jpg",
        "assets/images/futuristic_cities_2.jpg",
      ],
      projectLink: "https://myportfolio.com/futuristic-cities",
    ),
    Project(
      id: "6",
      title: "Digital Art: Futuristic Cities",
      description: "A series of digital artworks depicting futuristic cityscapes.",
      mainImagePath: "assets/images/futuristic_cities_main.jpg",
      additionalImagePaths: [
        "assets/images/futuristic_cities_1.jpg",
        "assets/images/futuristic_cities_2.jpg",
      ],
      projectLink: "https://myportfolio.com/futuristic-cities",
    ),
    Project(
      id: "7",
      title: "Digital Art: Futuristic Cities",
      description: "A series of digital artworks depicting futuristic cityscapes.",
      mainImagePath: "assets/images/futuristic_cities_main.jpg",
      additionalImagePaths: [
        "assets/images/futuristic_cities_1.jpg",
        "assets/images/futuristic_cities_2.jpg",
      ],
      projectLink: "https://myportfolio.com/futuristic-cities",
    ),
    Project(
      id: "8",
      title: "Digital Art: Futuristic Cities",
      description: "A series of digital artworks depicting futuristic cityscapes.",
      mainImagePath: "assets/images/futuristic_cities_main.jpg",
      additionalImagePaths: [
        "assets/images/futuristic_cities_1.jpg",
        "assets/images/futuristic_cities_2.jpg",
      ],
      projectLink: "https://myportfolio.com/futuristic-cities",
    ),
    Project(
      id: "9",
      title: "Digital Art: Futuristic Cities",
      description: "A series of digital artworks depicting futuristic cityscapes.",
      mainImagePath: "assets/images/futuristic_cities_main.jpg",
      additionalImagePaths: [
        "assets/images/futuristic_cities_1.jpg",
        "assets/images/futuristic_cities_2.jpg",
      ],
      projectLink: "https://myportfolio.com/futuristic-cities",
    ),
    Project(
      id: "10",
      title: "Digital Art: Futuristic Cities",
      description: "A series of digital artworks depicting futuristic cityscapes.",
      mainImagePath: "assets/images/futuristic_cities_main.jpg",
      additionalImagePaths: [
        "assets/images/futuristic_cities_1.jpg",
        "assets/images/futuristic_cities_2.jpg",
      ],
      projectLink: "https://myportfolio.com/futuristic-cities",
    ),
  ];
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
        itemCount: projectList.length, // Replace with actual project count
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
                    child: Text(projectList[index].title ,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
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