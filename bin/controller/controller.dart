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
  static int cured_cont = 0;

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
    if (res.body == 'null') {
      return List.empty();
    } else {
      return patientResponseProviderFromJson(res.body).patients;
    }
  }

  static Future<int> addPatient(Patient patient) async {
    Consult? consult = await areFreeConsults();
    Doctor? doctor = await areDoctorsAvailable();

    //Añado el paciente a la base de datos
    if (await Services.post(patient.toJson(), url_patients)) {
      //Hay que traerse de nuevo el paciente debido que anteriormente no tiene id, hasta que se la asigna firebase
      Patient new_patient = await getPatients().then((value) => value!.last);

      if (consult != null && doctor != null) {
        consult.id_patient = new_patient.id;
        consult.id_doctor = doctor.id!;
        consult.isBusy = true;

        //Actualizo la consulta que se encuentra como libre y la cambio a ocupada.
        if (await updateConsult(consult)) {
          List<Consult>? consults = await getConsults();

          return consults!.indexWhere((consult_db) =>
              consult_db.id ==
              consult
                  .id); //Se ha actualizado la consulta y devuelvo el numero de consulta
        }
      } else if (await addPatientToWaitingList(
          WaitingList(id_patient: new_patient.id)))
        return -2; //Se ha metido el paciente en la lista de espera.
    }

    return -1; //Error inesperado, no se llego a concretar ninguna de las operaciones
  }

  static Future<Consult?> areFreeConsults() async {
    List<Consult>? consults = await getConsults();
    for (Consult consult in consults!) {
      if (!(consult.isBusy!)) return consult;
    }

    return null;
  }

  static Future<int> getHistoryNumber() async {
    List<Patient>? patients = await getPatients();

    bool flag = false;
    int tempID;
    do {
      flag = false;
      tempID = Random().nextInt(10000) + 1;

      for (Patient patient in patients!) {
        if (patient.history_number == tempID) flag = true;
      }
    } while (flag);

    return tempID;
  }

  static Future<Patient?> getPatientByID(String id) async {
    List<Patient>? patients = await getPatients();
    for (var patient in patients!) {
      if (patient.id == id) return patient;
    }
  }

  /* Consultas */

  static Future<List<Consult>?> getConsults() async {
    Response res = await Services.get(url_consults);
    return consultResponseProviderFromJson(res.body).consults;
  }

  static Future<Consult?> getConsultByID(String id) async {
    List<Consult>? consults = await getConsults();
    for (var consult in consults!) {
      if (id == consult.id) return consult;
    }
  }

  static Future<bool> updateConsult(Consult consult) async {
    final url =
        'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/consults/${consult.id}.json';

    return await Services.put(consult.toJson(), url);
  }

  static Future<bool> releaseConsult(String id_consult) async {
    bool is_updated_to_free_state = false;

    final url =
        'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/consults/$id_consult.json';

    List<Consult>? consults = await getConsults();
    if (consults != null) {
      for (var consult in consults) {
        if (consult.id == id_consult) {
          //Esta condicion es para evaluar que se elimine el paciente de la base de datos.
          if (await deletePatientFromPatientsList(consult.id_patient!)) {
            consult.id_doctor = '';
            consult.id_patient = '';
            consult.isBusy = false;

            //Actualizo los nuevos valores a la consulta y la cambio a consulta a estado libre
            is_updated_to_free_state =
                await Services.put(consult.toJson(), url);
            if (is_updated_to_free_state) cured_cont += 1;
          }
        }
      }
    }

    return is_updated_to_free_state;
  }

  static Future<bool> deletePatientFromPatientsList(String id_patient) async {
    final url =
        'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/patients/$id_patient.json';

    return await Services.delete(url);
  }

  /* Doctores */
  static Future<List<Doctor>?> getDoctors() async {
    Response res = await Services.get(url_doctors);
    if (res.body == 'null') {
      return List.empty();
    } else {
      return doctorResponseProviderFromJson(res.body).doctors;
    }
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

    if (res.body == 'null') {
      return List.empty();
    } else {
      return waitingListResponseProviderFromJson(res.body).id_patients;
    }
  }

  static Future<bool> addPatientToWaitingList(WaitingList waitingList) async {
    return await Services.post(waitingList.toJson(), url_waiting_list);
  }

  static Future<Consult?> releaseWaitingList(
      List<WaitingList> waiting_list, String id_consult) async {
    WaitingList id_patient_in_list = waiting_list
        .first; //Obtengo la primera id de los pacientes que este en espera.
    Doctor? doctor =
        await areDoctorsAvailable(); //Obtengo al doctor que se encuentre libre.

    //Si se llega a eliminar el paciente de lista de espera
    if (await deletePatientInWaitingList(id_patient_in_list.id!)) {
      //Creo una nueva consulta y la actualizo
      Consult consult = Consult(
          id: id_consult,
          id_doctor: doctor!.id,
          id_patient: id_patient_in_list.id_patient,
          isBusy: true);
      if (await updateConsult(consult))
        return consult; //Si todo se resuelve bien devuelvo la consulta.
    }
    return null;
  }

  static Future<bool> deletePatientInWaitingList(String id_waiting_list) async {
    final url =
        'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/waiting_list/$id_waiting_list.json';

    return await Services.delete(url);
  }
}
