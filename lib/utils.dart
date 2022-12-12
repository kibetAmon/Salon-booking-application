import 'package:intl/intl.dart';
//Utilities
class Utilities {
  static DateTime createMockDate (final String time){
    final int hour = int.parse(time.split(".")[0]);
    final int minute = int.parse(time.split(":")[1]);
    
    return DateTime(1999, 1, 1, hour, minute);

  }

  static String toFormatted(final DateTime dateTime) => DateFormat('yyyy-MM-dd').format(dateTime);
  static String to12hour(final DateTime dateTime) => DateFormat("h:mma").format(dateTime);
  static DateTime removeTime(final DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);
}