import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../entities/Event/Events.dart';
import '../../services/Event/EventService.dart'; // Import EventService

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final EventService _eventService = EventService(); // EventService instance
  String? _imagePath;
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newEvent = Event(
          _titleController.text,
          '', // Image URL will be added after upload
          _selectedDate,
          _descriptionController.text,
        );

        if (_imagePath != null) {
          final imageFile = File(_imagePath!);
          await _eventService.addEvent(newEvent, imageFile);
          Navigator.pop(context, newEvent);
        } else {
          throw Exception('Please select an image.');
        }
      } catch (e) {
        print('Error adding event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _imagePath != null
                        ? 'Image selected: ${_imagePath!.split('/').last}'
                        : 'No image selected',
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select Image'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}
