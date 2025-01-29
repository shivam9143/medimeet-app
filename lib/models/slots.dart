
class Slot {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  Slot({required this.id, required this.startTime, required this.endTime, required this.isAvailable});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isAvailable: json['is_available'],
    );
  }
}