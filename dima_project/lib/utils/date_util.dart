import 'package:dima_project/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final localizations = CupertinoLocalizations.of(context);

    int hour = date.hour;
    final String period = hour < 12
        ? localizations.anteMeridiemAbbreviation
        : localizations.postMeridiemAbbreviation;
    hour = _hourOfPeriod(hour);
    return '${_formatHour(hour)}:${_formatMinute(date.minute)} $period';
  }

  static String getFormattedDateAndTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final localizations = CupertinoLocalizations.of(context);

    int hour = date.hour;
    final String period = hour < 12
        ? localizations.anteMeridiemAbbreviation
        : localizations.postMeridiemAbbreviation;
    hour = _hourOfPeriod(hour);
    return '${_formatHour(hour)}:${_formatMinute(date.minute)} $period, ${_formatDate(date)}';
  }

  static int _hourOfPeriod(int hour) {
    if (hour == 0) {
      return 12;
    } else if (hour > 12) {
      return hour - 12;
    } else {
      return hour;
    }
  }

  static String _formatHour(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  static String _formatMinute(int minute) {
    return minute.toString().padLeft(2, '0');
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateBasedOnToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  static String convertMonthToString(int month) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  static Map<String, List<Message>> groupMediasByDate(List<dynamic> medias) {
    Map<String, List<Message>> groupedMedias = {};

    for (var media in medias) {
      final DateTime messageDate =
          DateTime.fromMillisecondsSinceEpoch(media.time.seconds * 1000);

      //final String dateKey = DateUtil.formatDateBasedOnToday(messageDate);
      final String dateKey;
      if (messageDate
          .isAfter(DateTime.now().subtract(const Duration(days: 365)))) {
        dateKey = DateFormat.MMMM().format(messageDate);
      } else {
        dateKey = DateFormat.yMMMM().format(messageDate);
      }

      if (groupedMedias.containsKey(dateKey)) {
        groupedMedias[dateKey]!.add(media);
      } else {
        groupedMedias[dateKey] = [media];
      }
    }

    return groupedMedias;
  }
}
