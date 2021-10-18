class WaitingList {
  String? id;
  String? id_patient;

  WaitingList({this.id, this.id_patient});

  factory WaitingList.fromJson(parsedJson, String id) =>
      WaitingList(id: id, id_patient: parsedJson['id_patient']);

  Map<String, dynamic> toJson() => {'id_patient': id_patient};
}
