import 'package:Artounsi/pages/Job/JobService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:Artounsi/entities/Job/Job.dart';

class JobCreationPage extends StatefulWidget {
  final Job? job;

  JobCreationPage({Key? key, this.job}) : super(key: key);

  @override
  _JobCreationPageState createState() => _JobCreationPageState();
}

class _JobCreationPageState extends State<JobCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final JobService _jobService = JobService();

  String _title = '';
  String _description = '';
  File? _mainImage;
  String? _mainImageUrl;
  List<File> _additionalImages = [];
  List<String> _additionalImageUrls = [];
  String _jobLink = '';

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _title = widget.job!.title;
      _description = widget.job!.description;
      _jobLink = widget.job!.JobLink;
      _mainImageUrl = widget.job!.mainImagePath;
      _additionalImageUrls = widget.job!.additionalImagePaths;
    }
  }

  Future<void> _pickImage(ImageSource source, {bool isMain = false}) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isMain) {
          _mainImage = File(pickedFile.path);
          _mainImageUrl = null;
        } else {
          _additionalImages.add(File(pickedFile.path));
        }
      });
    }
  }

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate() && (_mainImage != null || _mainImageUrl != null)) {
      _formKey.currentState!.save();
      try {
        Job newJob = Job(
          id: widget.job?.id ?? '',
          title: _title,
          description: _description,
          mainImagePath: _mainImageUrl ?? '',
          additionalImagePaths: _additionalImageUrls,
          JobLink: _jobLink,
        );

        if (widget.job == null) {
          await _jobService.addJob(newJob, _mainImage!, additionalImages: _additionalImages);
        } else {
          await _jobService.modifyJob(
            newJob.id,
            newJob,
            newMainImage: _mainImage,
            newAdditionalImages: _additionalImages.isNotEmpty ? _additionalImages : null,
          );
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
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
              initialValue: _title,
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
              initialValue: _description,
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
            _buildImagePicker('Additional Images (Optional)', isMain: false, isAdditional: true),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _jobLink,
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
              child: Text(widget.job == null ? 'Create Job' : 'Update Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, {bool isMain = false, bool isAdditional = false}) {
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
                child: _buildImageContainer(_mainImage, _mainImageUrl),
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
                itemCount: _additionalImages.length + _additionalImageUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index < _additionalImageUrls.length) {
                    return Image.network(_additionalImageUrls[index], fit: BoxFit.cover);
                  } else if (index < _additionalImageUrls.length + _additionalImages.length) {
                    return Image.file(_additionalImages[index - _additionalImageUrls.length], fit: BoxFit.cover);
                  } else {
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
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(File? image, String? imageUrl) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: image != null
          ? Image.file(image, fit: BoxFit.cover)
          : imageUrl != null
          ? Image.network(imageUrl, fit: BoxFit.cover)
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
