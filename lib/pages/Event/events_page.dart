import 'package:flutter/material.dart';
import 'add_event_page.dart';
import '../../entities/Event/Events.dart';
import 'event_details_page.dart';
import '../../services/Event/EventService.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Event> events = [];
  final EventService _eventService = EventService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      List<Event> fetchedEvents = await _eventService.getEvents();
      setState(() {
        events = fetchedEvents;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching events: $e');
      print(stackTrace);
      setState(() {
        isLoading = false;
      });
    }
  }


  void _navigateToAddEventPage() async {
    bool? eventAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEvent()),
    );
    if (eventAdded == true) {
      _fetchEvents();
    }
  }

  void _navigateToEventDetailsPage(Event event) async {
    bool? shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)),
    );
    if (shouldReload == true) {
      _fetchEvents();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEventPage,
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _navigateToEventDetailsPage(events[index]),
            child: Card(
              margin: EdgeInsets.all(8.0),
              color: Colors.white10,
              child: Column(
                children: [
                  Image.network(
                    events[index].imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  ListTile(
                    title: Text(
                      events[index].title,
                      style: TextStyle(color: Colors.blue),
                    ),
                    subtitle: Text(
                      '${events[index].date.toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
