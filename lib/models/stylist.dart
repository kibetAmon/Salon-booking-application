import 'package:salon_booking_app/models/service.dart';
import 'package:salon_booking_app/models/schedule.dart';

//Stylist details
class Stylist {
  final String name;
  final String job;
  final String bio;
  final String email;
  final String phoneNumber;
  final String imageUrl;
  final List<Service> services;
  final Schedule schedule;

//Constructor initialization
  Stylist({
    required this.name,
    required this.job,
    required this.bio,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
    required this.services,
    required this.schedule,
  });
}