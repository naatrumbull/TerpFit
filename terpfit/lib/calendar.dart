import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_date_provider.dart';

class SimpleDatePickerButton extends StatelessWidget {
  const SimpleDatePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calendar_month),
      onPressed: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final appDateProvider = Provider.of<AppDateProvider>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: appDateProvider.currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      appDateProvider.changeDate(picked);
    }
  }
}
