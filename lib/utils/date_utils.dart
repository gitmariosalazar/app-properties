/// returns date in dd-MM-yyyy format
String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
}

/// returns time in HH:mm format
String formatTime(DateTime date) {
  return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

/// returns date and time in dd-MM-yyyy HH:mm format
String formatDateTime(DateTime date) {
  return "${formatDate(date)} ${formatTime(date)}";
}

/// converts ISO 8601 date string to dd-MM-yyyy format
String formatFromIsoDate(String isoDate, {String pattern = 'dd-MM-yyyy'}) {
  try {
    DateTime date = DateTime.parse(isoDate);
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  } catch (e) {
    return isoDate;
  }
}
