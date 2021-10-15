import 'dart:convert';

import '../models/consult.dart';

class ConsultResponseProvider {
  List<Consult>? consults;

  ConsultResponseProvider.fromJson(parsedJson) {
    consults = getConsults(parsedJson);
  }

  List<Consult> getConsults(Map<String, dynamic> parsedJson) {
    List<String>? id_values = parsedJson.keys.toList();
    return id_values
        .map((id_consult) =>
            Consult.fromJson(parsedJson[id_consult], id_consult))
        .toList();
  }

  Map<String, dynamic> toJson() =>
      {'consult': consults!.map((consult) => consult.toJson())};
}

ConsultResponseProvider consultResponseProviderFromJson(String json) =>
    ConsultResponseProvider.fromJson(jsonDecode(json));

String consultResponseProviderToJson(Consult data) => jsonEncode(data.toJson());
