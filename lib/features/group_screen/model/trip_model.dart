class Trip {
  final String? id; // Trip ID from the API
  final String name;
  final String
  date; // You might want a more specific date type like DateTime later
  final String? aiSummary; // AI-generated summary from the API
  final String?
  currency; // Currency string from API (e.g. "S$ Singapore dollar")

  Trip({
    this.id,
    required this.name,
    required this.date,
    this.aiSummary,
    this.currency,
  });
}
