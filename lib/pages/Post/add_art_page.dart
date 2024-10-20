import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddArtPage extends StatefulWidget {
  const AddArtPage({Key? key}) : super(key: key);

  @override
  _AddArtPageState createState() => _AddArtPageState();
}

class _AddArtPageState extends State<AddArtPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _softwareController = TextEditingController();
  File? _mainArtImage;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _mainArtImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Artwork'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Art Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Art Description',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _tagsController,
                  label: 'Tags (Optional)',
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _softwareController,
                  label: 'Software Used (Optional)',
                ),
                const SizedBox(height: 16.0),
                _buildImagePicker(),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Artwork'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        errorStyle: TextStyle(color: Colors.red),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Art Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: _mainArtImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _mainArtImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Text(
                      'Tap to upload image',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ),
        if (_mainArtImage == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Required main image',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _mainArtImage != null) {
      _formKey.currentState!.save();
      // TODO: Implement save art logic here
      print('Title: ${_titleController.text}');
      print('Description: ${_descriptionController.text}');
      print('Tags: ${_tagsController.text}');
      print('Software Used: ${_softwareController.text}');
      print('Main Image: ${_mainArtImage?.path}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Art added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      _softwareController.clear();
      setState(() {
        _mainArtImage = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all required fields and select an image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _softwareController.dispose();
    super.dispose();
  }
}
