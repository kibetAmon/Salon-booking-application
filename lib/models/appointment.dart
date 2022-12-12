import 'package:salon_booking_app/models/stylist.dart';
import 'package:salon_booking_app/models/service.dart';

//Appointment
class Appointment {
  final int appointmentID;
  final DateTime date;
  final String time;
  final Stylist stylist;
  final List<Service> services;

//Constructor initialization

  Appointment(
      {required this.appointmentID,
        required this.date,
        required this.time,
        required this.stylist,
        required this.services
      });

  // Get service price
  double getServicesPrice() {
    double price = 0;
    services.forEach((element) => price += element.price);

    return price;
  }

  double getTax() {
    return double.parse((getServicesPrice() * 0.13).toStringAsFixed(2));
  }

  double getTotal() {
    return double.parse((getServicesPrice() + getTax()).toStringAsFixed(2));
  }

}

