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

  static Future<List<Consult>?> getConsults() async {
    var res = await Services.get(urlConsults);
    return consultResponseProviderFromJson(res.body).consults;
  }

  //El siguiente método no se usa, lo hizo el pendejo de Flavio
  static Future<bool> addConsult(Consult consult) async =>
      Services.post(consult.toJson(), urlConsults);

  static Future<bool> releaseConsult(String id_consult) async {
    late bool res;

    final url =
        'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/consults/$id_consult.json';

    var consults = await getConsults();
    if (consults != null) {
      for (var consult in consults) {
        if (consult.id == id_consult) {
          consult.id_doctor = '';
          consult.id_patient = '';
          consult.isBusy = false;

          res = await Services.put(consult.toJson(), url);
        }
      }
    }

    return res;
  }

  static Future<List<Doctor>?> getDoctors() async {
    var res = await Services.get(urlDoctors);
    return doctorResponseProviderFromJson(res.body).doctors;
  }

  static Future<Doctor?> areDoctorsAvailable() async {
    var doctors = await getDoctors();
    var consults = await getConsults();

    if (consults != null && doctors != null) {
      for (Consult consult in consults) {
        for (Doctor doctor in doctors) {
          if (consult.id_doctor != doctor.id) return doctor;
        }

        return null;
      }
    }
  }

  static Future<Doctor?> getDoctorByID(String id) async {
    List<Doctor>? doctors = await getDoctors();

    for (Doctor d in doctors!) {
      if (id == d.id) return d;
    }
  }
}
