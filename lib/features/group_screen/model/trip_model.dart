class Trip {
  final String? id; // Trip ID from the API
  final String name;
  final String
  date; // You might want a more specific date type like DateTime later
  final String? aiSummary; // AI-generated summary from the API

  Trip({this.id, required this.name, required this.date, this.aiSummary});
}
