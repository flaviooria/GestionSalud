import 'package:http/http.dart' as http;
import 'models/patient.dart';
import 'utils/utils.dart';
import 'controller/controller.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final urlDoctors = Uri.parse(
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/doctors.json');
  final resDoctors = await http.get(urlDoctors);

  print('Bienvenido al centro de salud de Martos');
  Utils.separationLine();

  var flag = false;
  do {
    print('''
    1. Admisión de un cliente
    2. Liberar una consulta
    3. Ver la cola de espera
    4.Ver el estado actual de las consultas
    5.Salir
    Elige una opción:
    ''');
    switch (stdin.readLineSync()) {
      case '1':
        print(await admisionCliente()
            ? 'Cliente añadido con éxito'
            : 'Error al añadir el cliente');
        break;
      case '2':
        break;
      case '3':
        break;
      case '4':
        break;
      case '5':
        print('Hasta la próxima');
        flag = true;

        break;
      default:
        print('Opción no válida');
    }
  } while (!flag);

  /* final url = Uri.parse(
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/doctors.json');
  final res = await http.get(url);

  var doctors = doctorResponseProviderFromJson(res.body).doctors;

  doctors?.forEach((element) {
    print('''
        id: ${element.id}
        Doctor: ${element.name}
        Especialidad: ${element.specialty}
  ''');
  }); */
}

Future<bool> admisionCliente() async {
  String? dni, name, surnames, sympton;

  stdout.write('Introduce tu dni:');
  dni = stdin.readLineSync();

  stdout.write('Introduce tu nombre:');
  name = stdin.readLineSync();

  stdout.write('Introduce tus apellidos:');
  surnames = stdin.readLineSync();

  stdout.write('Introduce tus síntomas:');
  sympton = stdin.readLineSync();

  return Controller.addPatient(Patient(
      dni: dni,
      name: name,
      surnames: surnames,
      sympton: sympton,
      historyNumber: await Controller.getHistoryNumber()));
}
