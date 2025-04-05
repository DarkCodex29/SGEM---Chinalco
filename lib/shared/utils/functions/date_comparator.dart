bool dateIsAfter(DateTime date1, DateTime date2) {
  final a = DateTime(date1.year, date1.month, date1.day);
  final b = DateTime(date2.year, date2.month, date2.day);

  return a.isAfter(b);
}

bool dateIsBefore(DateTime date1, DateTime date2) {
  final a = DateTime(date1.year, date1.month, date1.day);
  final b = DateTime(date2.year, date2.month, date2.day);

  return a.isBefore(b);
}
