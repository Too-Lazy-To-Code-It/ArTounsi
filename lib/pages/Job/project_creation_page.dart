import 'package:Artounsi/pages/Job/JobService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../entities/Job/Job.dart';

class JobCreationPage extends StatefulWidget {
  final Job? job; // Add this parameter to accept a job for editing

  JobCreationPage({Key? key, this.job}) : super(key: key);

  @override
  _JobCreationPageState createState() => _JobCreationPageState();
}


class _JobCreationPageState extends State<JobCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final JobService _jobService = JobService();


  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _title = widget.job!.title;
      _description = widget.job!.description;
      _jobLink = widget.job!.JobLink;
      // Convert URLs to Files if necessary or load them properly
    }
  }


  String _title = '';
  String _description = '';
  File? _mainImage;
  List<File> _additionalImages = [];
  String _jobLink = '';

  Future<void> _pickImage(ImageSource source, {bool isMain = false}) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isMain) {
          _mainImage = File(pickedFile.path);
        } else {
          _additionalImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate() && _mainImage != null) {
      _formKey.currentState!.save();
      try {
        Job newJob = Job(
          id: widget.job?.id ?? '',
          title: _title,
          description: _description,
          mainImagePath: '', // Will be replaced by uploaded URL
          additionalImagePaths: [],
          JobLink: _jobLink,
        );

        if (widget.job == null) {
          // Add new job
          await _jobService.addJob(newJob, _mainImage!, additionalImages: _additionalImages);
        } else {
          // Update existing job
          await _jobService.modifyJob(newJob.id, newJob, newMainImage: _mainImage, newAdditionalImages: _additionalImages);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Job ${widget.job == null ? 'created' : 'updated'} successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save job: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'Create New Job' : 'Edit Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Title',
                errorStyle: TextStyle(color: Colors.red),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Description',
                errorStyle: TextStyle(color: Colors.red),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
            SizedBox(height: 16.0),
            _buildImagePicker('Main Job Image', isMain: true),
            SizedBox(height: 16.0),
            _buildImagePicker('Additional Images (Optional)',
                isMain: false, isAdditional: true),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Job Link (Optional)',
                errorStyle: TextStyle(color: Colors.red),
              ),
              onSaved: (value) {
                _jobLink = value ?? '';
              },
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _submitJob,
              child: Text('Create Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label,
      {bool isMain = false, bool isAdditional = false}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            if (isMain)
              GestureDetector(
                onTap: () => _showImageSourceDialog(isMain: true),
                child: _buildImageContainer(_mainImage),
              ),
            if (!isMain && isAdditional)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _additionalImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _additionalImages.length) {
                    return GestureDetector(
                      onTap: () => _showImageSourceDialog(),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Icon(Icons.add),
                      ),
                    );
                  }
                  return Image.file(_additionalImages[index],
                      fit: BoxFit.cover);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(File? image) {
    return Container(
      height: MediaQuery.sizeOf(context).width * 0.6,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: image != null
          ? Image.file(image, fit: BoxFit.cover)
          : Center(child: Text('Upload image')),
    );
  }

  void _showImageSourceDialog({bool isMain = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera, isMain: isMain);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery, isMain: isMain);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
