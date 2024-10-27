import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../entities/Event/Events.dart';
import '../../services/Event/EventService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifyEvent extends StatefulWidget {
  final DocumentReference eventRef;

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
  String? _existingImageUrl;
  bool _isLoading = false; // Loading state
  bool _hasUnsavedChanges = false; // Unsaved changes state

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    DocumentSnapshot doc = await widget.eventRef.get();
    if (doc.exists) {
      var event = Event.fromMap(doc.data() as Map<String, dynamic>);
      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _selectedDate = event.date;
        _existingImageUrl = event.imageUrl;
        _imagePath = null;
      });
    }
  }

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
        _hasUnsavedChanges = true; // Mark as having unsaved changes
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        _hasUnsavedChanges = true; // Mark as having unsaved changes
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading state
      });
      try {
        final updatedEvent = Event(
          _titleController.text,
          '',
          _selectedDate,
          _descriptionController.text,
        );

        await _eventService.modifyEvent(
          widget.eventRef,
          updatedEvent,
          newImage: _imagePath != null && File(_imagePath!).existsSync() ? File(_imagePath!) : null,
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
      } finally {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content: Text('You have unsaved changes. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
          ],
        ),
      )) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Modify Event'),
        ),
        body: _isLoading // Conditional rendering based on loading state
            ? Center(child: CircularProgressIndicator())
            : Form(
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
                onChanged: (_) => _hasUnsavedChanges = true, // Track changes
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
                onChanged: (_) => _hasUnsavedChanges = true, // Track changes
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _imagePath != null && _imagePath!.isNotEmpty
                          ? 'Image selected: ${_imagePath!.split('/').last}'
                          : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                          ? 'Existing image loaded: ${_existingImageUrl!.split('/').last}'
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
              if (_imagePath != null && _imagePath!.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.cover,
                  ),
                )
              else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.network(
                    _existingImageUrl!,
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
      ),
    );
  }
}
