import 'package:Artounsi/pages/Job/project_creation_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../../entities/Job/CustomFloatingActionButton.dart';
import '../../entities/Job/job.dart';

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

  late List<Job> JobList;
  int _counter = 2;

  @override
  void initState() {
    super.initState();
    JobList = [
      Job(
        id: generateRandomId(),
        title: "Sunset Beach",
        description: "A beautiful oil painting of a sunset at the beach.",
        mainImagePath: "assets/images/cow.jpg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/sunset-beach",
      ),
      Job(
        id: generateRandomId(),
        title: "Urban Sketch",
        description: "A series of urban sketches capturing city life.",
        mainImagePath: "assets/images/child.jpeg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/urban-sketch",
      ),
      Job(
        id: generateRandomId(),
        title: "Abstract Emotions",
        description: "An abstract painting series exploring human emotions.",
        mainImagePath: "assets/images/marine.jpg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/abstract-emotions",
      ),
      Job(
        id: generateRandomId(),
        title: "Nature Photography",
        description: "A collection of nature photographs from various national parks.",
        mainImagePath: "assets/images/Classy.jpg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/nature-photography",
      ),
      Job(
        id: generateRandomId(),
        title: "Digital Art: Futuristic Cities",
        description: "A series of digital artworks depicting futuristic cityscapes.",
        mainImagePath: "assets/images/muslimFather.jpeg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/futuristic-cities",
      ),
      Job(
        id: generateRandomId(),
        title: "Nature Photography",
        description: "A collection of nature photographs from various national parks.",
        mainImagePath: "assets/images/capital.jpeg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/nature-photography",
      ),
      Job(
        id: generateRandomId(),
        title: "Game Card",
        description: "A collection of nature photographs from various national parks.",
        mainImagePath: "assets/images/cardGame.jpeg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/nature-photography",
      ),
      Job(
        id: generateRandomId(),
        title: "Mosque",
        description: "A collection of nature photographs from various national parks.",
        mainImagePath: "assets/images/mos.jpeg",
        additionalImagePaths: [
          "assets/images/marine.jpg",
          "assets/images/muslimFather.jpeg",
          "assets/images/cardGame.jpeg",
          "assets/images/mos.jpeg",
        ],
        JobLink: "https://myportfolio.com/nature-photography",
      ),
    ];
  }

  void _showJobDetails(BuildContext context, Job Job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery
                .of(context)
                .size
                .height * 0.7),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Job.title,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Image.asset(
                      Job.mainImagePath,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                    SizedBox(height: 16),
                    Text(
                      Job.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Additional Images:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: Job.additionalImagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              Job.additionalImagePaths[index],
                              fit: BoxFit.cover,
                              width: 100,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      child: Text(
                        "Job Link",
                        style: TextStyle(fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        // TODO: Implement link opening functionality
                      },
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _counter <= 0 ? 1 : _counter,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: JobList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showJobDetails(context, JobList[index]);
                        },
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    JobList[index].mainImagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(JobList[index].title),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            CustomFloatingActionButton(
              onPressedAdd: _incrementCounter,
              onPressedSubtract: _decrementCounter,
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProjectCreationPage()),
                  );
                },
                child: Icon(Icons.add),
              ),
            ),
          ],
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


