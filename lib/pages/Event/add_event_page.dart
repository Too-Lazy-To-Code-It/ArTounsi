import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../entities/Event/Events.dart';
import '../../services/Event/EventService.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final EventService _eventService = EventService();
  String? _imagePath;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _tunisianCities = [
    'Tunis', 'Sfax', 'Sousse', 'Gabès', 'Bizerte', 'Ariana', 'Gafsa',
    'Monastir', 'Kairouan', 'Ben Arous', 'Tozeur', 'Kasserine', 'Médenine',
    'Nabeul', 'Mahdia', 'Sidi Bouzid', 'Kébili', 'Jendouba', 'Beja',
    'Zaghouan', 'Siliana', 'Tataouine', 'Manouba'
  ];

  String? _selectedCity;

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image.')),
        );
        return;
      }
      if (_selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location.')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        User? user = FirebaseAuth.instance.currentUser;
        String username = user != null ? user.displayName ?? 'Anonymous' : 'Anonymous';
        final newEvent = Events(
          '',
          _titleController.text,
          '',
          _selectedDate,
          _descriptionController.text,
          _selectedCity!,
          username,
        );

        final imageFile = File(_imagePath!);
        final imageUrl = await _eventService.uploadImage(imageFile);
        newEvent.imageUrl = imageUrl;

        await _eventService.addEvent(newEvent, imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added successfully!')),
        );

        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCity = null;
          _imagePath = null;
          _selectedDate = DateTime.now();
        });

        Navigator.pop(context, true);
      } catch (e) {
        print('Error adding event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
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
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                hint: Text('Select Location'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Location',
                ),
                items: _tunisianCities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
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
                  child: Image.file(
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
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
