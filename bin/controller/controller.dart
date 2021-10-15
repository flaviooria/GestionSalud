import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import '../models/consult.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../providers/consult_provider.dart';
import '../providers/doctor_provider.dart';
import '../providers/patient_provider.dart';
import '../services/services.dart';

class Controller {
  static String urlPatients =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/patients.json';

  static String urlConsults =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/consults.json';

  static String urlDoctors =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/doctors.json';

  static Future<bool> addPatient(Patient patient) async {
    return Services.post(patient.toJson(), urlPatients);
  }

  static Future<int> getHistoryNumber() async {
    final res = await Services.get(urlPatients);
    // ignore: omit_local_variable_types
    List<Patient>? patients =
        patientResponseProviderFromJson(res.body).patients;

    var flag = false;
    int tempID;
    do {
      flag = false;
      tempID = Random().nextInt(10000) + 1;
      // ignore: omit_local_variable_types
      for (Patient p in patients!) {
        // ignore: unrelated_type_equality_checks
        if (p.historyNumber == tempID) flag = true;
      }
    } while (flag);

    return tempID;
  }

  static Future<Response> getConsults() async =>
      await Services.get(urlConsults);

  //El siguiente método no se usa, lo hizo el pendejo de Flavio
  static Future<bool> addConsult(Consult consult) async =>
      Services.post(consult.toJson(), urlConsults);

  static void releaseConsult() {}

  static Future<Response> getDoctors() async => await Services.get(urlDoctors);

  static Future<Doctor?> areDoctorsAvailable() async {
    var resDoctors = await getDoctors();
    var resConsults = await getConsults();
    // ignore: omit_local_variable_types
    List<Doctor>? doctors =
        doctorResponseProviderFromJson(resDoctors.body).doctors;

    // ignore: omit_local_variable_types
    List<Consult>? consults =
        consultResponseProviderFromJson(resConsults.body).consults;

    for (Consult consult in consults!) {
      for (Doctor doctor in doctors!) {
        if (consult.id_doctor == doctor.id) return doctor;
      }

      return null;
    }
  }
}
