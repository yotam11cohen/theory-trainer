class DrivingLesson {
  final String id;
  final String vehicleId;
  final String category;
  final int orderIndex;
  final String title;
  final String description;

  const DrivingLesson({
    required this.id,
    required this.vehicleId,
    required this.category,
    required this.orderIndex,
    required this.title,
    required this.description,
  });

  factory DrivingLesson.fromJson(Map<String, dynamic> json) => DrivingLesson(
        id: json['id'] as String,
        vehicleId: json['vehicle_id'] as String,
        category: json['category'] as String,
        orderIndex: json['order_index'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_id': vehicleId,
        'category': category,
        'order_index': orderIndex,
        'title': title,
        'description': description,
      };
}
