import 'package:Artounsi/pages/Job/JobService.dart';
import 'package:Artounsi/pages/Job/project_creation_page.dart';
import 'package:flutter/material.dart';
import '../../entities/Job/CustomFloatingActionButton.dart';
import 'package:Artounsi/entities/Job/Job.dart';

class JobPage extends StatefulWidget {
  const JobPage({Key? key}) : super(key: key);

  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  final JobService _jobService = JobService();
  List<Job> _jobList = [];
  int _counter = 2;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    try {
      List<Job> jobs = await _jobService.getJobs();
      setState(() {
        _jobList = jobs;
      });
    } catch (e) {
      print('Failed to fetch jobs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch jobs: $e')),
      );
    }
  }

  Future<void> _deleteJob(String jobId) async {
    try {
      await _jobService.deleteJob(jobId);
      _fetchJobs(); // Refresh the job list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete job: $e')),
      );
    }
  }

  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      job.title,
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Image.network(
                      job.mainImagePath,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                    SizedBox(height: 16),
                    Text(
                      job.description,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Additional Images:",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: job.additionalImagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              job.additionalImagePaths[index],
                              fit: BoxFit.cover,
                              width: 100,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    if (job.JobLink.isNotEmpty)
                      InkWell(
                        child: Text(
                          "Job Link",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                        onTap: () {
                          // TODO: Implement link opening functionality
                        },
                      ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text("Edit"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobCreationPage(job: job),
                              ),
                            ).then((_) => _fetchJobs());
                          },
                        ),
                        TextButton(
                          child: Text("Delete"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteJob(job.id);
                          },
                        ),
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _jobList.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _counter <= 0 ? 1 : _counter,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _jobList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _showJobDetails(context, _jobList[index]);
                      },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  _jobList[index].mainImagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_jobList[index].title),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobCreationPage()),
          ).then((_) => _fetchJobs());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter =1;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter=2;
      }
    });
  }
}
