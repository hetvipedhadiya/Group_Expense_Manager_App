class PersonModel {
  int? eventID;
  dynamic? userID;
  String userName;
  int? hostID;
  String? userImage;

  PersonModel({
    required this.eventID,
    this.userID,
    required this.userName,
    this.hostID,
    this.userImage,
  });

  // Convert from JSON
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      userID: json['userID'],
      eventID: json['eventID'],
      userName: json['userName'] ?? '',
      hostID: json['hostId'],
      userImage: json['UserImage'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userName': userName,
      'UserImage': userImage,
      'eventID': eventID,
      'hostId': hostID,
    };

    if (userID != null) {
      json['userID'] = userID;
    }
    return json;
  }

  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      if (userID != null) 'userID': userID,
      'userName': userName,
      'eventID': eventID,
      'hostID': hostID,
      'UserImage': userImage,
    };
  }

  // Convert from SQLite Map
  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      userID: map['userID'],
      eventID: map['eventID'],
      userName: map['userName'],
      hostID: map['hostID'],
      userImage: map['UserImage'],
    );
  }
}
