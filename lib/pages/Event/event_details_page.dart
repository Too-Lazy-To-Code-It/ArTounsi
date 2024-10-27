import 'package:flutter/material.dart';
import '../../entities/Event/Events.dart';
import 'Full_Screen_Img.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [
    {
      'name': 'Alice',
      'comment': 'Fantastic event! Well organized.'
    },
    {
      'name': 'Bob',
      'comment': 'Great experience, but a bit crowded.'
    },
    {
      'name': 'Charlie',
      'comment': 'Loved every moment of it!'},
  ];

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add({
          'name': 'John Doe', // You could replace this with a dynam
          'comment': _commentController.text,
        });
        _commentController.clear();
      });
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
                  backgroundImage:
                  AssetImage('assets/images/profile_picture.jpg'),
                ),
                SizedBox(width: 8),
                Text(
                  'Organizer Name', // Replace with actual data if available
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
              children: _comments.map((commentData) {
                return _buildCommentItem(
                  context,
                  commentData['name'],
                  commentData['comment'],
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

  Widget _buildCommentItem(
      BuildContext context, String name, String comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment),
        ],
      ),
    );
  }
}
