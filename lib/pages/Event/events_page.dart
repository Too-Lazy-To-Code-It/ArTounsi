import 'package:flutter/material.dart';
import 'add_event_page.dart';
import '../../entities/Event/Events.dart';
import 'event_details_page.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Event> events = [];

  @override
  void initState() {
    events.add(Event(
        'Art Exhibition',
        'assets/images/event1.jpg',
        DateTime(2023, 7, 15),
        'A showcase of contemporary art featuring works from renowned and upcoming artists. This exhibition includes paintings, sculptures, and mixed media, all exploring themes of modern society and human expression.'));
    events.add(Event(
        'Digital Art Workshop',
        'assets/images/event2.jpg',
        DateTime(2023, 8, 1),
        'Join us for an interactive digital art workshop where participants will learn cutting-edge techniques in digital drawing and painting. This session is perfect for both beginners and seasoned artists looking to expand their digital skill set.'));
    events.add(Event(
        'Photography Masterclass',
        'assets/images/1692849792746760.jpg',
        DateTime(2023, 9, 10),
        'A hands-on masterclass with professional photographers, focusing on portrait and landscape photography. Attendees will gain insights into composition, lighting, and post-processing to take their photography skills to the next level.'));
    events.add(Event(
        'Sculpture Exhibition',
        'assets/images/1700320394628361.jpg',
        DateTime(2023, 9, 25),
        'Explore an inspiring collection of sculptures from various artists, highlighting the beauty of form and material. This exhibition features large installations and intricate designs, providing a glimpse into the world of contemporary sculpture art.'));
    super.initState();
  }

  void _navigateToAddEventPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEvent()),
    );
  }

  void _navigateToEventDetailsPage(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEventPage,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _navigateToEventDetailsPage(events[index]),
            child: Card(
              margin: EdgeInsets.all(8.0),
              color: Colors.white10,
              child: Column(
                children: [
                  Image.asset(
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
