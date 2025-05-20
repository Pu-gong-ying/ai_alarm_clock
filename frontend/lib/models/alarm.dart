class Alarm {
  final int id;
  final DateTime time;
  final String sound;
  final bool vibration;
  final List<bool> repeatDays;
  final String? description;
  bool isEnabled;

  Alarm({
    required this.id,
    required this.time,
    required this.sound,
    required this.vibration,
    required this.repeatDays,
    this.description,
    this.isEnabled = true,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as int,
      time: DateTime.parse(json['time'] as String),
      sound: json['sound'] as String,
      vibration: json['vibration'] as bool,
      repeatDays: List<bool>.from(json['repeatDays'] as List),
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'sound': sound,
      'vibration': vibration,
      'repeatDays': repeatDays,
      'description': description,
      'isEnabled': isEnabled,
    };
  }

  Alarm copyWith({
    int? id,
    DateTime? time,
    String? sound,
    bool? vibration,
    List<bool>? repeatDays,
    String? description,
    bool? isEnabled,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      repeatDays: repeatDays ?? this.repeatDays,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  String toString() {
    return 'Alarm(id: $id, time: $time, sound: $sound, vibration: $vibration, repeatDays: $repeatDays, description: $description, isEnabled: $isEnabled)';
  }
} 