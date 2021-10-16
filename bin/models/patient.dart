class Patient {
  String? id;
  String? dni;
  String? name;
  String? surnames;
  String? sympton;
  int? historyNumber;

  Patient(
      {this.id,
      this.dni,
      this.name,
      this.surnames,
      this.sympton,
      this.historyNumber});

  factory Patient.fromJson(parsedJson, [String? id]) => Patient(
      id: id,
      dni: parsedJson['dni'],
      name: parsedJson['name'] ?? 'Sin datos',
      surnames: parsedJson['surnames'] ?? 'Sin datos',
      sympton: parsedJson['sympton'] ?? 'Sin datos',
      historyNumber: parsedJson['history_number'] ?? -1);

  Map<String, dynamic> toJson() => {
        'dni': dni,
        'name': name,
        'surnames': surnames,
        'sympton': sympton,
        'historyNumber': historyNumber
      };
}
