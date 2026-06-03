class EventModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String location;
  final String eventDate;
  final int totalTickets;
  final int ticketsSold;
  final int price;
  final String category;
  final String status;
  final String? posterColor;
  final String? organizerName;

  EventModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.location,
    required this.eventDate,
    required this.totalTickets,
    required this.ticketsSold,
    required this.price,
    required this.category,
    required this.status,
    this.posterColor,
    this.organizerName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'],
        userId: json['user_id'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
        eventDate: json['event_date'],
        totalTickets: json['total_tickets'],
        ticketsSold: json['tickets_sold'] ?? 0,
        price: json['price'],
        category: json['category'],
        status: json['status'],
        posterColor: json['poster_color'],
        organizerName: json['organizer'] != null ? json['organizer']['name'] : null,
      );

  // ✅ Sisa tiket
  int get remainingTickets => totalTickets - ticketsSold;

  // ✅ Progress penjualan (0.0 - 1.0)
  double get salesProgress => totalTickets > 0 ? ticketsSold / totalTickets : 0.0;

  // ✅ Format harga
  String get formattedPrice => price == 0 ? 'Gratis' : 'Rp ${_formatNumber(price)}';

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}rb';
    return '$n';
  }
}