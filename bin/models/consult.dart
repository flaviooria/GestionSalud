class Consult {
  String? id;
  String? id_doctor;
  String? id_patient;
  bool? isBusy;

  Consult({this.id, this.id_doctor, this.id_patient, this.isBusy});

  factory Consult.fromJson(parsedJson, [String? id_consult]) => Consult(
      id: id_consult,
      id_doctor: parsedJson['id_doctor'] ?? 'Sin datos',
      id_patient: parsedJson['id_patient'] ?? 'Sin datos',
      isBusy: parsedJson['isBusy'] ?? false);

  Map<String, dynamic> toJson() =>
      {'id_doctor': id_doctor, 'id_patient': id_patient, 'isBusy': isBusy};
}
