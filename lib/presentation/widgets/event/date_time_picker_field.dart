import 'package:flutter/material.dart';

class DateTimePickerField extends StatelessWidget {
  const DateTimePickerField({
    super.key,
    required this.label,
    required this.selectedDateTime,
    required this.onChanged,
    this.firstDate,
    this.validator,
    this.isRequired = false,
  });

  final String label;
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final String? Function(DateTime?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: selectedDateTime != null
                ? '${_formatDate(selectedDateTime!)} à ${_formatTime(selectedDateTime!)}'
                : '',
          ),
          validator: validator != null
              ? (value) {
                  return validator!(selectedDateTime);
                }
              : null,
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDateTime ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(firstDate ?? now)
          ? initialDate
          : firstDate ?? now,
      firstDate: firstDate ?? now,
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    onChanged(pickedDateTime);
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
