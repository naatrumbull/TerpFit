
import 'package:flutter/material.dart';
import 'calendar_events.dart';
import 'package:provider/provider.dart';

class CalendarForm extends StatefulWidget {
  const CalendarForm({super.key});

  @override
  State<CalendarForm> createState() {
    return _CalendarFormState();
  }
}

class _CalendarFormState extends State<CalendarForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Consumer<SelectedDay>(
              builder: (context, value, child) => TextFormField(
                    decoration: const InputDecoration(hintText: 'Workout'),
                    autocorrect: false,
                    obscureText: false,
                    autofocus: false,
                    validator: (value) {
                      if (null == value || value.isEmpty) {
                        return 'No workout provided';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      value.insertEvent(newValue as String);
                    },
                  )),
          ElevatedButton(
            onPressed: () {
              final state = _formKey.currentState;
              if (state!.validate()) {
                setState(() {
                  state.save();
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }
}
