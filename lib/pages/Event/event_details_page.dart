import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Event/Events.dart';
import 'Full_Screen_Img.dart';
import '../../services/Event/EventService.dart';
import 'modify_event_page.dart';
import '../../entities/Event/Comments.dart';
import '../../services/Event/ComlmentService.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  final List<DocumentReference> _commentRefs = []; // Store document references
  final CommentService _commentService = CommentService();
  bool _isLoading = false;
  bool _isEventDeleted = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        // Optionally show loading state
        _isLoading = true;
      });

      List<Comment> comments = await _commentService.getComments();
      setState(() {
        _comments.addAll(comments);
      });

      await _saveCommentsDocument(comments);
    } catch (e) {
      // Handle errors, e.g., show a message to the user
      print('Error loading comments: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state
      });
    }
  }

  Future<void> _saveCommentsDocument(List<Comment> comments) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('commentsCollection').doc('commentsDocId');
      final commentsData = {
        'comments': comments.map((comment) => comment.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      };
      await docRef.set(commentsData);
    } catch (e) {
      // Handle errors while saving the document
      print('Error saving comments document: $e');
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
        DocumentReference eventRef = querySnapshot.docs.first.reference;
        await eventService.deleteEvent(eventRef);

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
        name: 'John Doe',
        comment: _commentController.text,
      );

      DocumentReference newDocRef = await _commentService.addComment(newComment);

      setState(() {
        _comments.add(newComment);
        _commentRefs.add(newDocRef);
        _commentController.clear();
      });
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

  Future<void> _deleteComment(int index) async {
    if (index < _commentRefs.length) {
      DocumentReference docRef = _commentRefs[index];
      await _commentService.deleteComment(docRef); // Use the document reference to delete

      setState(() {
        _comments.removeAt(index);
        _commentRefs.removeAt(index); // Remove the reference as well
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment deleted!')),
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullscreenImage(
                      imageUrls: [widget.event.imageUrl],
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: ClipRRect(
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
            ),
            SizedBox(height: 16),
            Text(
              widget.event.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
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
            Text(
              widget.event.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${widget.event.date.toString().split(' ')[0]}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have joined the event!')),
                  );
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
                return _buildCommentItem(
                  context,
                  comment,
                  index,
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
            bottom: 10,
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
