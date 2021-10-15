import 'dart:convert';

import '../models/patient.dart';

class PatientResponseProvider {
  List<Patient>? patients;

  PatientResponseProvider({this.patients});

  PatientResponseProvider.fromJson(parsedJson) {
    patients = getPatients(parsedJson);
  }

  List<Patient> getPatients(Map<String, dynamic> parsedJson) {
    List<String>? id_values = parsedJson.keys.toList();
    return id_values
        .map((id_patient) =>
            Patient.fromJson(parsedJson[id_patient], id_patient))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'patients':
            List<dynamic>.from(patients!.map((patient) => patient.toJson()))
      };
}

PatientResponseProvider patientResponseProviderFromJson(String json) =>
    PatientResponseProvider.fromJson(jsonDecode(json));

String patientResponseProviderToJson(Patient data) => jsonEncode(data.toJson());
