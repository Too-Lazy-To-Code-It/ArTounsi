class Event {
  final String title;
  final String imageUrl;
  final DateTime date;
  final String description;

  Event(this.title, this.imageUrl, this.date, this.description);

  @override
  String toString() {
    return 'Event{title: $title, imageUrl: $imageUrl, date: $date, description: $description}';
  }
}
