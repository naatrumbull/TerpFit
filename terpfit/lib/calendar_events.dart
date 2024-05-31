import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import "calendar_utils.dart";
import 'calendar_form.dart';
import 'package:provider/provider.dart';

// Used https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/utils.dart
// as a reference for building this code

class SelectedDay extends ChangeNotifier {
  DateTime currDay = DateTime.now();

  void insertEvent(String description) {
    List<Event> list = getEventsForDay(currDay);
    if (list.isEmpty) {
      kEvents.addAll({currDay: []});
    }

    getEventsForDay(currDay).add(Event(description));
    notifyListeners();
  }
}

class TableEvents extends StatefulWidget {
  const TableEvents({super.key});

  @override
  TableEventsExampleState createState() => TableEventsExampleState();
}

class TableEventsExampleState extends State<TableEvents> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ...getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null; // Important to clean those
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedEvents.value = getEventsForDay(selectedDay);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = getEventsForDay(end);
    }
  }

  Widget calendarWidget() {
    double height = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height * 0.25
        : MediaQuery.of(context).size.height * 0.95;
    double width = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width * 0.95
        : MediaQuery.of(context).size.width * 0.5;
    return Consumer<SelectedDay>(
        builder: (context, value, child) => LayoutBuilder(
            builder: (context, constraints) => Center(
                child: SizedBox(
                    width: width,
                    height: height,
                    child: TableCalendar<Event>(
                      firstDay: kFirstDay,
                      lastDay: kLastDay,
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      calendarFormat: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? CalendarFormat.week
                          : CalendarFormat.twoWeeks,
                      availableCalendarFormats:
                          MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? const {
                                  CalendarFormat.week: 'Week',
                                }
                              : {
                                  CalendarFormat.twoWeeks: 'Month',
                                },
                      rangeSelectionMode: _rangeSelectionMode,
                      eventLoader: getEventsForDay,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      calendarStyle: const CalendarStyle(
                        // Use `CalendarStyle` to customize the UI
                        outsideDaysVisible: false,
                      ),
                      onDaySelected: _onDaySelected,
                      onRangeSelected: _onRangeSelected,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    )))));
  }

  Widget eventListWidget() {
    return Expanded(
      child: ValueListenableBuilder<List<Event>>(
        valueListenable: _selectedEvents,
        builder: (context, value, _) {
          return value.isEmpty
              ? const Text("No Events")
              : ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Workout Calendar'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Flex(
              direction: orientation == Orientation.portrait
                  ? Axis.vertical
                  : Axis.horizontal,
              children: [
                calendarWidget(),
                const SizedBox(height: 8.0),
                eventListWidget(),
              ]);
        },
      ),
      floatingActionButton: Consumer<SelectedDay>(
          builder: (context, value, child) => FloatingActionButton(
              onPressed: () {
                value.currDay = _selectedDay as DateTime;
                setState(() async {
                  await addEvent();
                });
              },
              child: const Icon(Icons.calendar_today_sharp))),
    );
  }

  Future<void> addEvent() async {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Add Future Workout Plan'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[CalendarForm()],
            ),
          ),
        );
      },
    );
  }
}
