class Doctor {
  String? id;
  String? name;
  String? specialty;

  Doctor({this.id, this.name, this.specialty});

  factory Doctor.fromJson(Map<String, dynamic> json, [String? id_doctor]) =>
      Doctor(id: id_doctor, name: json['name'], specialty: json['specialty']);

  Map<String, dynamic> toJson() => {'name': name, 'specialty': specialty};

  @override
  String toString() {
    // TODO: implement toString
    return 'nombre: ${name ?? 'Sin datos'}, especialidad: ${specialty ?? 'Sin datos'}';
  }
}
