import 'dart:collection';
import 'dart:math';

import 'package:http/http.dart';

import '../models/consult.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/waiting_list.dart';
import '../providers/consult_provider.dart';
import '../providers/doctor_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/waiting_list_provider.dart';
import '../services/services.dart';

class Controller {
  static String url_patients =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/patients.json';

  static String url_consults =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/consults.json';

  static String url_doctors =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/doctors.json';

  static String url_waiting_list =
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/waiting_list.json';

  /* Pacientes */
  static Future<List<Patient>?> getPatients() async {
    Response res = await Services.get(url_patients);
    return patientResponseProviderFromJson(res.body).patients;
  }

  static Future<bool> addPatient(Patient patient) async {
    return Services.post(patient.toJson(), url_patients);
  }

  static Future<int> getHistoryNumber() async {
    final res = await Services.get(url_patients);

    // ignore: omit_local_variable_types
    List<Patient>? patients =
        patientResponseProviderFromJson(res.body).patients;

    bool flag = false;
    int tempID;
    do {
      flag = false;
      tempID = Random().nextInt(10000) + 1;

      // ignore: omit_local_variable_types
      for (Patient p in patients!) {
        if (p.historyNumber == tempID) flag = true;
      }
    } while (flag);

    return tempID;
  }

  static Future<Patient?> getPatientByID(String id) async {
    List<Patient>? patients = await getPatients();
    for (var patient in patients!) {
      if (id == patient.id) return patient;
    }
  }

/* Consultas */
  static Future<List<Consult>?> getConsults() async {
    Response res = await Services.get(url_consults);
    return consultResponseProviderFromJson(res.body).consults;
  }

  //El siguiente método no se usa, lo hizo el pendejo de Flavio
  static Future<bool> addConsult(Consult consult) async =>
      Services.post(consult.toJson(), url_consults);

  static Future<bool> releaseConsult(String id_consult) async {
    late bool res;

    final url =
        'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/consults/$id_consult.json';

    List<Consult>? consults = await getConsults();
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

  /* Doctores */
  static Future<List<Doctor>?> getDoctors() async {
    Response res = await Services.get(url_doctors);
    return doctorResponseProviderFromJson(res.body).doctors;
  }

  static Future<Doctor?> areDoctorsAvailable() async {
    List<Doctor>? doctors = await getDoctors();
    List<Consult>? consults = await getConsults();

    if (consults != null && doctors != null) {
      for (var consult in consults) {
        for (var doctor in doctors) {
          if (consult.id_doctor != doctor.id) return doctor;
        }

        return null;
      }
    }
  }

  static Future<Doctor?> getDoctorByID(String id) async {
    List<Doctor>? doctors = await getDoctors();
    for (var d in doctors!) {
      if (id == d.id) return d;
    }
  }

/* Lista de espera */
  static Future<List<WaitingList>?> getWaitingList() async {
    Response res = await Services.get(url_waiting_list);

    return waitingListResponseProviderFromJson(res.body).id_patients;
  }
}
