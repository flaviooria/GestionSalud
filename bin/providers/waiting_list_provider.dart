import 'dart:convert';

import '../models/waiting_list.dart';

class WaitingListResponseProvider {
  List<WaitingList>? id_patients;

  WaitingListResponseProvider({this.id_patients});

  WaitingListResponseProvider.fromJson(parsedJson) {
    id_patients = getWaitingPatients(parsedJson);
  }

  List<WaitingList> getWaitingPatients(Map<String, dynamic> parsedJson) {
    List<String>? ids = parsedJson.keys.toList();

    List<WaitingList> id_patients =
        ids.map((id) => WaitingList.fromJson(parsedJson[id], id)).toList();

    return List.from(id_patients);
  }

  Map<String, dynamic> toJson() => {
        'patients': List<dynamic>.from(
            id_patients!.map((id_patient) => id_patient.toJson()))
      };
}

WaitingListResponseProvider waitingListResponseProviderFromJson(String json) =>
    WaitingListResponseProvider.fromJson(jsonDecode(json));

String waitingListResponseProviderToJson(WaitingList data) =>
    jsonEncode(data.toJson());
