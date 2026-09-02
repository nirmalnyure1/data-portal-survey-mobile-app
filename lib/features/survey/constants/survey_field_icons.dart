import 'package:flutter/material.dart';

/// Field-type icons — mirrors `frontend/src/components/survey-builder/field-types.ts`.
abstract final class SurveyFieldIcons {
  static const Map<String, IconData> byType = {
    'text': Icons.text_fields,
    'textarea': Icons.notes,
    'number': Icons.tag,
    'select': Icons.arrow_drop_down_circle,
    'multiselect': Icons.check_box,
    'phone': Icons.phone,
    'email': Icons.mail,
    'date': Icons.calendar_today,
    'time': Icons.schedule,
    'datetime': Icons.calendar_today,
    'url': Icons.link,
    'file': Icons.upload_file,
    'rating': Icons.star,
    'range': Icons.tune,
    'yes_no': Icons.toggle_on,
    'location': Icons.place,
  };

  static IconData forType(String fieldType) =>
      byType[fieldType] ?? Icons.text_fields;
}
