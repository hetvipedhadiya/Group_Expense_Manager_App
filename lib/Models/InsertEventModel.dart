class Event {
  dynamic? eventID;
  String eventName;
  DateTime eventDate;
 int? hostID;

  Event({
    this.eventID,
    required this.eventName,
    required this.eventDate,
    this.hostID
  });

  // Convert from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventID: json['eventID'],
      eventName: json['eventName'],
      eventDate: DateTime.parse(json['eventDate']),
     hostID: json['hostID'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'hostID':hostID
    };
  }
  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      if (eventID != null) 'eventID': eventID,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'hostID': hostID,
    };
  }

  // Convert from SQLite Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventID: map['eventID'],
      eventName: map['eventName'],
      eventDate: DateTime.parse(map['eventDate']),
      hostID: map['hostID'],
    );
  }
}
