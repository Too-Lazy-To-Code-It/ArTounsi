import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../entities/Event/Events.dart';
import '../../entities/Event/Comments.dart';
import '../../services/Event/CommentService.dart';
import '../../services/Event/EventService.dart';
import 'Full_Screen_Img.dart';
import 'modify_event_page.dart';
import 'WeatherService.dart';

class EventDetailsPage extends StatefulWidget {
  final Events event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  final List<DocumentReference> _commentRefs = [];
  final CommentService _commentService = CommentService();
  bool _isLoading = false;
  bool _isEventDeleted = false;
  bool _isWeatherLoading = false;
  Map<String, dynamic> _weatherData = {};

  @override
  void initState() {
    super.initState();
    _loadComments(widget.event.id);
    _fetchWeather(widget.event.location);
  }

  Future<void> _fetchWeather(String location) async {
    setState(() {
      _isWeatherLoading = true;
      _weatherData = {};
    });

    try {
      // Construct the API URL using the provided location
      final apiKey = '31bcf9db936c49f6ba8c2ea1fe313bfb'; // Your API key
      final apiUrl = 'https://api.weatherbit.io/v2.0/current?city=$location&key=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Ensure the data array exists and has items
        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          // Access the first item in the data array
          final weatherInfo = jsonResponse['data'][0];

          setState(() {
            _weatherData = {
              'temp': weatherInfo['temp'],
              'description': weatherInfo['weather']['description'],
              'icon': weatherInfo['weather']['icon'],
              'rh': weatherInfo['rh'],
              'wind_spd': weatherInfo['wind_spd'],
            };
          });
        } else {
          setState(() {
            _weatherData = {}; // Clear data if empty
          });
        }
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      setState(() {
        _isWeatherLoading = false;
        _weatherData = {};
      });
      print('Error fetching weather data: $error');
    }

    setState(() {
      _isWeatherLoading = false;
    });
  }




  Future<void> _loadComments(String eventId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      List<Comment> comments = await _commentService.getCommentsForEvent(eventId);
      print("Fetched comments: $comments");

      setState(() {
        _comments.clear();
        _commentRefs.clear();

        _comments.addAll(comments);
        _commentRefs.addAll(comments.map((comment) {
          DocumentReference ref = _commentService.getCommentReference(comment.id);
          print("Comment: ${comment.name}, Reference: $ref");
          return ref;
        }));
      });
    } catch (e) {
      print('Error loading comments: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<void> _deleteEvent() async {
    final eventService = EventService();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('title', isEqualTo: widget.event.title)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String eventId = querySnapshot.docs.first.id;
        await eventService.deleteEvent(eventId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event deleted!')),
        );
        setState(() {
          _isEventDeleted = true;
        });
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  void _confirmDeleteEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Event"),
          content: Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                _deleteEvent();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      Comment newComment = Comment(
        id: '',
        name: 'John Doe',
        comment: _commentController.text,
        eventId: widget.event.id,
      );

      try {
        DocumentReference newDocRef = await _commentService.addComment(newComment);

        setState(() {
          newComment = Comment(
            id: newDocRef.id,
            name: newComment.name,
            comment: newComment.comment,
            eventId: newComment.eventId,
          );

          _comments.add(newComment);
          _commentRefs.add(newDocRef);
          _commentController.clear();
        });
      } catch (e) {
        print('Error adding comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment.')),
        );
      }
    }
  }

  void _modifyEvent() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('title', isEqualTo: widget.event.title)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference eventRef = querySnapshot.docs.first.reference;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModifyEvent(eventRef: eventRef),
        ),
      ).then((result) {
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event modified successfully!')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event not found!')),
      );
    }
  }

  void _confirmDeleteComment(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteComment(index);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(int index) async {
    if (index < _commentRefs.length) {
      DocumentReference docRef = _commentRefs[index];

      print("Deleting comment at index $index with ID: ${docRef.id}");

      await _commentService.deleteComment(docRef);

      setState(() {
        _comments.removeAt(index);
        _commentRefs.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment deleted!')),
      );
    } else {
      print("Index out of bounds: $index");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.event.imageUrl.startsWith('http')
                      ? Image.network(
                    widget.event.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    widget.event.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      widget.event.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Organizer Name
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/profile_picture.jpg'),
                ),
                SizedBox(width: 8),
                Text(
                  'Organizer Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Event Description
            Text(
              widget.event.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Event Location with Icon
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'Location: ${widget.event.location}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),


            _isWeatherLoading
                ? Center(child: CircularProgressIndicator())
                : _weatherData.isNotEmpty
                ? WeatherWidget(weatherData: _weatherData)
                : Text(
              'Weather data not available.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),



            SizedBox(height: 16),

            // Event Date with Icon
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'Date: ${widget.event.date.toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Join Event Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have joined the event!')),
                  );
                },
                child: Text('Join Event'),
              ),
            ),
            SizedBox(height: 24),

            // Comments Section
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),

            // Comments List
            Column(
              children: _comments.asMap().entries.map((entry) {
                int index = entry.key;
                Comment comment = entry.value;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(comment.name),
                    subtitle: Text(comment.comment),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteComment(index),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Add Comment Section
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: _addComment,
                child: Text('Submit Comment'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 70,
            right: 16,
            child: FloatingActionButton(
              onPressed: _confirmDeleteEvent,
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            ),
          ),
          Positioned(
            bottom: 7,
            right: 16,
            child: FloatingActionButton(
              onPressed: _modifyEvent,
              child: Icon(Icons.edit),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildCommentItem(BuildContext context, Comment comment, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(comment.name, style: TextStyle(color: Colors.amber),),
        subtitle: Text(comment.comment),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _confirmDeleteComment(index),
        ),
      ),
    );
  }
}