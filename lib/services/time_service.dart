import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeService {
  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm')
        .format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
    return formattedTime;
  }
}
