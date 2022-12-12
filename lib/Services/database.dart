import 'package:salon_booking_app/Services/authentication.dart';
import 'package:salon_booking_app/models/appointment.dart';
import 'package:salon_booking_app/models/salon_details.dart';
import 'package:salon_booking_app/models/schedule.dart';
import 'package:salon_booking_app/models/service.dart';
import 'package:salon_booking_app/models/stylist.dart';
import 'package:salon_booking_app/models/user.dart';
import 'package:salon_booking_app/utils.dart';
import 'package:salon_booking_app/Services/schedule_finder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//Database initialization
class Database{
  static final instance = Database();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  //init
  late SalonDetails salonDetails;
  final List<Stylist> stylists = [];

  //Call the methods
  Future<void> load() async {
    print("loading database stuff into database");
    await _loadSalonDetails();
    await _loadStylists();
    await _loadUserData();
  }

  //load salon details
  Future<void> _loadSalonDetails() async {
    final detailsDocument = await _firestore.collection('details').doc('details').get();
    if (detailsDocument.exists){
      final String salonName = detailsDocument.data()!['salonName'];
      final String tagline = detailsDocument.data()!['tagline'];
      final String description = detailsDocument.data()!['aboutUs'];
      salonDetails = SalonDetails(
          salonName: salonName,
          tagline: tagline,
          description: description,
      );
    }
  }

  // load stylist
Future<void> _loadStylists() async {
    stylists.clear();

    final stylistCollection = await _firestore.collection('stylists').get();
    if (stylistCollection.docs.isEmpty) return;
    for(final stylistDocument in stylistCollection.docs){
      final String name = stylistDocument.id;
      final String job = stylistDocument.data()['job'];
      final String bio =  stylistDocument.data()['bio'];
      final String email = stylistDocument.data()['email'];
      final String phoneNumber = stylistDocument.data()['phoneNumber'];
      final imageRef  = _storage.ref(
        'stylists/${name.split('')[0]}${name.split('')[1]}.jpg',
      );
      final imageUrl = await imageRef.getDownloadURL();
      final Map<String, dynamic> serviceMap = stylistDocument.data()['services'];
      final List<Service> services = serviceMap.entries
      .map(
              (entry) => Service(name: entry.key, price: entry.value.toDouble()
              ),
      )
      .toList();

      final Schedule schedule =  ScheduleFinder.findSchedule(name) as Schedule;
      final Stylist stylist = Stylist(
          name: name,
          job: job,
          bio: bio,
          email: email,
          phoneNumber: phoneNumber,
          imageUrl: imageUrl,
          services: services,
          schedule: schedule,
      );

      stylists.add(stylist);
    }
}

//Load User data
Future<void> _loadUserData() async {
    await _loadUserAppointment();
    final auth = Authentication.instance;
    final userDocument = await _firestore.collection('users').doc(auth.getCurrentUser().uniqueID).get();
    if(userDocument.exists){
      final List<String> favoriteStylists = List.from(userDocument.data()!['favoriteStylists']);
      auth.getCurrentUser().favoriteStylists.clear();
      for(final favoriteStylist in favoriteStylists){
        final Stylist stylist = stylists.firstWhere((stylist) =>
        stylist.name.toLowerCase()== favoriteStylist.toLowerCase(),
        );
        auth.getCurrentUser().favoriteStylists.add(stylist);
      }
    }

}

//Load User appointment
Future<void> _loadUserAppointment() async{
    final auth = Authentication.instance;
    final userDocument = await _firestore.collection('users').doc(auth.getCurrentUser().uniqueID).get();
    if((!userDocument.exists) || (userDocument.data()!.containsKey('upcomingAppointment'))){
      return;
    }

    final Map<String, dynamic> upcomingAppointment = userDocument.data()!['upcomingAppointment'];
    final Appointment? appointment = await findAppointment(
      upcomingAppointment['date'],
      upcomingAppointment['time'],
    );

    if(appointment != null){
      if (Utilities.removeTime(appointment.date).isBefore(Utilities.removeTime(DateTime.now()))){
        _firestore.collection('users').doc(auth.getCurrentUser().uniqueID).update(
          {
            'upcomingAppointment': FieldValue.delete(),
          },
        );
        return;
      }
      auth.getCurrentUser().setUpcomingAppointment(appointment);
    }


}

//Find Appointment
  Future<Appointment?> findAppointment(
      final String date,
      final String time,

      ) async{
    final appointmentDocument = await _firestore.doc('appointments/$date/$time/${Authentication.instance.getCurrentUser().uniqueID}')
        .get();
    if(appointmentDocument.exists){
      final DateTime _date = Utilities.removeTime(DateTime.parse(date));
      final int appointmentID = appointmentDocument['id'];
      var stylist;
      var services;
      final Appointment appointment = Appointment(
          appointmentID: appointmentID,
          date: _date,
          time: time,
          stylist: stylist,
          services: services
      );
      print('found user appointment: ${appointment.date}');

      return appointment;
    }
    return null;
  }
  void update(final String path, final Map<String, dynamic> data){
    _firestore.doc(path).set(data, SetOptions(merge: true));
  }


//find User
Future<BAUser?> findUser(final String uniqueID) async {
    final userDocument = await _firestore.collection('users').doc(uniqueID).get();
    if(userDocument.exists){
      final String fullName = userDocument.data()!['fullName'];
      final String emailAddress = userDocument.data()!['email'];
      final bool isDisabled = (userDocument.data()!.containsKey('disabled') &&
          (userDocument.data()!['disabled']));

      return BAUser(
        uniqueID: uniqueID,
        fullName: fullName,
        emailAddress: emailAddress,

        isDisabled: isDisabled,
      );
    }
    return null;
}

//Create User
Future<BAUser?> createUser({
  required final String uniqueID,
  required final String fullName,
  required final String email,
}) async {
    final userDocument = _firestore.collection('users').doc(uniqueID);
    if((await userDocument.get()).exists) return await findUser(uniqueID);
    userDocument.set(
        {
          'fullName': fullName,
          'email': email,
          'favoriteStylists' : [],

    },
    );
    return BAUser(
        uniqueID: uniqueID,
        fullName: fullName,
        emailAddress: email,
    );
}

//Create Appointment
Future<void> createAppointment(final Appointment appointment) async {
    final bool appointmentExists = await doesAppointmentExist(appointment);
    if (appointmentExists){
      print('Appointment exists!');
      return;
    }
    _firestore.doc('appointments/${Utilities.toFormatted(appointment.date)}/${appointment.time}/${Authentication.instance.getCurrentUser().uniqueID}')
        .set(
      {
        'id' : appointment.appointmentID,
        'name' : Authentication.instance.getCurrentUser().fullName,
        'stylist' : appointment.stylist.name,
        'services' : appointment.services.map((service) => service.name).toList(),
        'total' : appointment.getTotal(),
      }
    );
}

//cancel appointment
  Future<void> cancelAppointment(final Appointment appointment) async {
    final bool appointmentExists = await doesAppointmentExist(appointment);
    if (!appointmentExists) {
      print('Appointment does not exists');

      return;
    }
    await _firestore
        .doc('appointments/${Utilities.toFormatted(appointment.date)}/${appointment.time}/${Authentication.instance.getCurrentUser().uniqueID}')
        .delete();
  }

//Check if the appointment exist
Future<bool> doesAppointmentExist(final Appointment appointment) async{
    final appointmentDocument = await _firestore.doc('appointments/${Utilities.toFormatted(appointment.date)}/${appointment.time}/${Authentication.instance.getCurrentUser().uniqueID}').get();
    return appointmentDocument.exists;
}

//Check if the stylist is available
Future<bool> isStylistAvailable(
    final Stylist stylist,
    final DateTime dateTime,
    final String time,
    ) async {
  final appointmentCollection = await _firestore
      .collection('appointments/${Utilities.toFormatted(dateTime)}/$time')
      .get();
  if(appointmentCollection.docs.isNotEmpty) {
    for(final appointmentDocument in appointmentCollection.docs){
      final String stylistName = appointmentDocument.data()['stylist'];
      print(stylistName);
      if (stylist.name == stylistName) return false;
    }
  }
  return true;
}


}



