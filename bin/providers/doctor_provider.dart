import 'dart:convert';

import '../models/doctor.dart';

class DoctorResponseProvider {
  List<Doctor>? doctors;

  DoctorResponseProvider({this.doctors});

  DoctorResponseProvider.fromJson(parsedJson) {
    doctors = getDoctors(parsedJson);
  }

  List<Doctor> getDoctors(Map<String, dynamic> parsedJson) {
    List<String>? id_values = parsedJson.keys.toList();
    return id_values
        .map((id_doctor) => Doctor.fromJson(parsedJson[id_doctor], id_doctor))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'doctors': List<dynamic>.from(doctors!.map((doctor) => doctor.toJson()))
      };
}

DoctorResponseProvider doctorResponseProviderFromJson(String json) =>
    DoctorResponseProvider.fromJson(jsonDecode(json));

String doctorResponseProviderToJson(Doctor data) => json.encode(data.toJson());
