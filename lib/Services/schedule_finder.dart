import 'package:salon_booking_app/models/schedule.dart';
import 'package:salon_booking_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Schedule finder
class ScheduleFinder {
  static Future<Schedule?> findSchedule(final String name) async {
    final firestore = FirebaseFirestore.instance;
    final stylistDocument = await firestore.collection('stylists').doc(name).get();

    if (stylistDocument.exists) {
      final Map<String, List<String>> schedule = {};
      final Map<String, List<String>> workingHours = {};

      final Map<String, dynamic> scheduleMap = stylistDocument.data()!['schedule'];

      for (final entry in scheduleMap.entries){
        final String weekday = entry.key;

        // find the stylist's schedule.

        // this will find the start time and the end time.
        // convert them both to a mock date
        // and then format them in 12 hour format.
        final List<String> scheduleList = List.from(entry.value)
        .map(
              (hour) => Utilities.to12hour(
                Utilities.createMockDate(hour),
        ),
        )
        .toList();

        //this will find all the hours in between
        //this will be shown when a user goes to book appointment
        final List<String> hours = _hoursBetween(entry.value[0], entry.value[1]);

        // finally collect both into a map to return a valid Schedule object.
        schedule.addAll({weekday:scheduleList,});
        workingHours.addAll({weekday:hours,});
      }
      return Schedule(schedule: schedule, workingHours: workingHours);
    }
    return null;
  }
  static List<String> _hoursBetween(
      final String startTime,
      final String endTime,
      ){
    final List<String> hours = [];
    final openTime = Utilities.createMockDate(startTime);
    final closeTime = Utilities.createMockDate(endTime);
    DateTime currentTime = openTime;
    while(currentTime.isBefore(closeTime)){
      hours.add(Utilities.to12hour(currentTime));
      currentTime = currentTime.add(Duration(minutes: 30),
      );
    }
    return hours;
  }
}