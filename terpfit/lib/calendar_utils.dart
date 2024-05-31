import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

// Used https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/utils.dart


/// Example events.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}


/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

List<Event> getEventsForDay(DateTime day) {
  // Implementation example
  return kEvents[day] ?? [];
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
