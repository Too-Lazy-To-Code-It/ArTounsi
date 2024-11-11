import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../entities/Event/Events.dart';
import '../../entities/Event/Comments.dart';
import '../../services/Event/CommentService.dart';
import '../../services/Event/EventService.dart';
import 'modify_event_page.dart';
import 'WeatherService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/Event/JoinEvent.dart';

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
  Map<String, dynamic>? userData;
  String? currentUserUsername;
  int joinedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadComments(widget.event.id);
    _fetchWeather(widget.event.location);
    fetchUserData();
    _getJoinedCount();
  }

  Future<void> _getJoinedCount() async {
    int count = await joinevent().getJoinedCount(widget.event.id);
    setState(() {
      joinedCount = count;
    });
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userData = querySnapshot.docs.first.data();
        });
      } else {
        print('User document not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchWeather(String location) async {
    setState(() {
      _isWeatherLoading = true;
      _weatherData = {};
    });

    try {
      final apiKey = 'f5c316762b8e45e7a0a51f4e7862fdd5';
      final apiUrl = 'https://api.weatherbit.io/v2.0/current?city=$location&key=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
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
            _weatherData = {};
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
      String username = userData?['username'] ?? 'Unknown User';

      Comment newComment = Comment(
        id: '',
        name: username,
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
    String username = userData?['username'] ?? 'Unknown User';

    bool isOwnerEvent = (username == widget.event.username);



    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          if (isOwnerEvent) IconButton(
            icon: Icon(Icons.edit),
            onPressed: _modifyEvent,
          ),
          if (isOwnerEvent) IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDeleteEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 48,
                ),
                SizedBox(width: 8),
                Text(
                  'Created by ${widget.event.username}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),

            SizedBox(height: 16),

            Text(
              widget.event.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'Location:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            _isWeatherLoading
                ? Center(child: CircularProgressIndicator())
                : _weatherData.isNotEmpty
                ? WeatherWidget(
              weatherData: _weatherData,
              cityName: widget.event.location,
            )
                : Text(
              'Weather data not available.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            SizedBox(height: 16),
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
            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.people, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  '$joinedCount people joined',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  bool isUserAlreadyJoined = await joinevent().checkIfUserJoined(widget.event.id);

                  if (isUserAlreadyJoined) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You have already joined this event.')),
                    );
                    return;
                  }

                  bool? confirmJoin = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Join Event'),
                        content: Text('Are you sure you want to join this event?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Join'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmJoin == true) {
                    await joinevent().joinEvent(widget.event.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You have joined the event!')),
                    );
                  }
                },
                child: Text('Join Event'),
              ),


            ),
            SizedBox(height: 24),

            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Column(
              children: _comments.asMap().entries.map((entry) {
                int index = entry.key;
                Comment comment = entry.value;
                bool isOwnerComm = (username == comment.name);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(comment.name),
                    subtitle: Text(comment.comment),
                    trailing: isOwnerComm
                        ? IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteComment(index),
                    )
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

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