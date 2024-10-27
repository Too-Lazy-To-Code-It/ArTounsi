import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../entities/Event/Events.dart';
import '../../services/Event/EventService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifyEvent extends StatefulWidget {
  final DocumentReference eventRef; // Reference to the event to be modified

  ModifyEvent({required this.eventRef});

  @override
  _ModifyEventState createState() => _ModifyEventState();
}

class _ModifyEventState extends State<ModifyEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final EventService _eventService = EventService();
  String? _imagePath;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEventData(); // Load existing event data
  }

  // Load event data from Firestore
  Future<void> _loadEventData() async {
    DocumentSnapshot doc = await widget.eventRef.get();
    if (doc.exists) {
      var event = Event.fromMap(doc.data() as Map<String, dynamic>);
      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _selectedDate = event.date;
        _imagePath = event.imageUrl; // URL or local path
      });
    }
  }

  // Select date for the event
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

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path; // Local file path
      });
    }
  }

  // Submit the updated event
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create the updated event instance
        final updatedEvent = Event(
          _titleController.text,
          '',
          _selectedDate,
          _descriptionController.text,
        );

        // Call modifyEvent from the EventService
        await _eventService.modifyEvent(
          widget.eventRef,
          updatedEvent,
          newImage: _imagePath != null ? File(_imagePath!) : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        print('Error modifying event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Event'),
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
            if (_imagePath != null)
              Container(
                margin: EdgeInsets.only(top: 16),
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _imagePath!.startsWith('http') // Check if it's a URL
                    ? Image.network(
                  _imagePath!,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('Failed to load image'));
                  },
                )
                    : Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                ),
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
              child: Text('Update Event'),
            ),
          ],
        ),
      ),
    );
  }
}
