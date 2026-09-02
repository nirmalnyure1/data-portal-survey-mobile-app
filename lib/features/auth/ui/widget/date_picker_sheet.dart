import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme.dart';

class DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final String title;

  const DatePickerSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.title = 'Select Date',
  });

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _handleSave() {
    widget.onDateSelected(_selectedDate);
    Navigator.pop(context);
  }

  void _handleBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: ThemeColors.pageBackGroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Padding(
        padding: AppInsets.all20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Navigation
            Container(
              padding: AppInsets.v12,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      padding: AppInsets.all8,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: ThemeColors.black,
                        size: 20,
                      ),
                    ),
                  ),

                  // Title

                  // Save Button
                ],
              ),
            ),

            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeColors.black,
              ),
            ),
            // Date Picker
            Expanded(
              child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now(),
                  minimumYear: 1960,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
            ),

            GestureDetector(
              onTap: _handleSave,
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(text: 'Save', onPressed: _handleSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
