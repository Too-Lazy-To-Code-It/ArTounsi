class Event {
  final String title;
  final String imageUrl;
  final DateTime date;
  final String description;

  Event(this.title, this.imageUrl, this.date, this.description);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imagePath': imageUrl,
      'date': date.toIso8601String(), // Use ISO 8601 format for dates
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Event{title: $title, imageUrl: $imageUrl, date: $date, description: $description}';
  }
}
