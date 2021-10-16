import 'package:http/http.dart' as http;
import 'models/consult.dart';
import 'models/doctor.dart';
import 'models/patient.dart';
import 'models/waiting_list.dart';
import 'utils/utils.dart';
import 'controller/controller.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final urlDoctors = Uri.parse(
      'https://primer-proyecto-c8a1a-default-rtdb.europe-west1.firebasedatabase.app/doctors.json');
  final resDoctors = await http.get(urlDoctors);

  print('Bienvenido al centro de salud de Martos');
  Utils.separationLine();

  bool flag = false;
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
        await showConsults();
        stdout.write('Escoge la consulta a liberar: ');
        int consult_id = lectorInt();
        print(await releaseConsultByID(consult_id)
            ? 'Consulta liberada con exito'
            : 'Error al liberar la consulta');
        break;
      case '3':
        await seeWaitingQueue();
        break;
      case '4':
        await showConsults();
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

Future<void> seeWaitingQueue() async {
  List<WaitingList>? w_patients = await Controller.getWaitingList();
  for (var i = 0; i < w_patients!.length; i++) {
    WaitingList w_list = w_patients.elementAt(i);
    Patient? p_temp = await Controller.getPatientByID(w_list.id_patient!);

    print('''
===Paciente ${i + 1} en la cola===
*** Datos  de paciente ***
Nombre del paciente: ${p_temp!.name} ${p_temp.surnames}
Historia de el paciente: ${p_temp.historyNumber}
Sintomas del paciente: ${p_temp.sympton}
    ''');
  }
}

Future<bool> releaseConsultByID(int consult_id) async {
  List<Consult>? list_consult = await Controller.getConsults();
  return await Controller.releaseConsult(
      list_consult!.elementAt((consult_id - 1)).id!);
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

Future<void> showConsults() async {
  List<Consult>? consults = await Controller.getConsults();
  if (consults != null) {
    for (var i = 0; i < consults.length; i++) {
      Consult c = consults.elementAt(i);
      Doctor? d = await Controller.getDoctorByID(c.id_doctor!);

      print('''
******Consulta: ${i + 1}******
Nombre de el médico:${d!.name}
Especialidad: ${d.specialty}
Paciente:
      ''');
    }
  } else {
    print('Consultas no disponibles');
  }
}

int lectorInt() {
  return int.parse(stdin.readLineSync() as String);
}
