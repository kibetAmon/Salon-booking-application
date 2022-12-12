import 'package:salon_booking_app/models/stylist.dart';
import 'package:salon_booking_app/models/appointment.dart';
import 'package:salon_booking_app/Services/database.dart';
import 'package:salon_booking_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//User information
class BAUser {
  final String uniqueID;
  final String fullName;
  final String emailAddress;
  final bool isDisabled;
  final List<Stylist> favoriteStylists = [];

  Appointment? _upcomingAppointment = null;



//Constructor initialization
  BAUser({
    required this.uniqueID,
    required this.emailAddress,
    required this.fullName,
    this.isDisabled = false,
  });

//Favorite stylist
  bool isFavouriteStylist(final Stylist stylist) =>
      favoriteStylists.contains(stylist);


//Add favorite stylist
void addFavoriteStylist(final Stylist stylist){
  if (favoriteStylists.contains(stylist)) return;
  favoriteStylists.add(stylist);
  Database.instance.update(
    'users/$uniqueID',
    {
      'favoriteStylists' : favoriteStylists.map((e) => e.name).toList(),
    },
  );
}

// Remove favorite stylist
void removeFavoriteStylist(final Stylist stylist) {
  if(!favoriteStylists.contains(stylist)) return;
  favoriteStylists.remove(stylist);
  Database.instance.update(
    'users/$uniqueID',
    {
      'favoriteStylists' : favoriteStylists.map((e) => e.name).toList(),
    },
  );
}

//Get Upcoming appointment
Appointment? getUpcomingAppointment(){
  return _upcomingAppointment;
}

//Set upcoming appointment
Future<void> setUpcomingAppointment(
    final Appointment appointment, {
      final bool update = false,

}) async{
  this._upcomingAppointment = appointment;
  if(update) {
    Database.instance.update(
      'users/$uniqueID',
      {
        'upcomingAppointment' : {
          'date' : Utilities.toFormatted(appointment.date),
          'time' : appointment.time,
        }
      },
    );
  }
}

//Delete upcoming appointment
Future<void> deleteUpcomingAppointment()async {
  this._upcomingAppointment = null;
  Database.instance.update(
    'users/$uniqueID',
      {
      'upcomingAppointment' : FieldValue.delete(),
  },
  );
}

}