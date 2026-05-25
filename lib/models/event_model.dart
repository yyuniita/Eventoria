class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final String startDate;
  final String? endDate;
  final String? banner;
  final String status;
  final int? categoryId;
  final int userId;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    this.endDate,
    this.banner,
    required this.status,
    this.categoryId,
    required this.userId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        banner: json['banner'],
        status: json['status'],
        categoryId: json['category_id'],
        userId: json['user_id'],
      );
}