import 'package:flutter/material.dart';
import 'add_event_page.dart';
import '../../entities/Event/Events.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  List<Event> events = [];

  @override
  void initState() {
    events.add(Event('Art Exhibition', 'assets/images/event1.jpg', DateTime(2023, 7, 15), 'A showcase of contemporary art.'));
    events.add(Event('Digital Art Workshop', 'assets/images/event2.jpg', DateTime(2023, 8, 1), 'Learn digital art techniques.'));
    super.initState();
  }

  void _navigateToAddEventPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => add_event()),
    );

    if (result != null && result is Event) {
      setState(() {
        events.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddEventPage,
            tooltip: 'Add Event',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            color: Colors.blueAccent,
            child: Column(
              children: [
                Image.asset(
                  events[index].imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: ${events[index].imageUrl}');
                    return Container(
                      height: 200,
                      color: Colors.grey,
                      child: Center(
                        child: Text('Failed to load image'),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    events[index].title,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${events[index].date.toString().split(' ')[0]}\n${events[index].description}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),

    );
  }
}
