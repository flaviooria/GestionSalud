import 'models/consult.dart';
import 'models/doctor.dart';
import 'models/patient.dart';
import 'models/waiting_list.dart';
import 'utils/utils.dart';
import 'controller/controller.dart';
import 'dart:io';

void main(List<String> arguments) async {
  print('Bienvenido al centro de salud de Martos');
  Utils.separationLine();

  bool flag = false;
  do {
    print('''
    1. Admisión de un cliente
    2. Liberar una consulta
    3. Ver la cola de espera
    4. Ver el estado actual de las consultas
    5. Salir
    Elige una opción:
    ''');
    switch (stdin.readLineSync()) {
      case '1':
        int res = await admisionCliente();
        print(res >= 0
            ? 'Se le ha asignado la consulta ${res + 1}'
            : res == -2
                ? 'Se le ha añadido a la lista de espera'
                : 'Error inesperado');
        break;
      case '2':
        if (await showBusyConsults()) {
          stdout.write('Escoge la consulta a liberar: ');
          int consult_id = lectorInt();
          await releaseConsultByID(consult_id);
        }

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
}

Future<void> seeWaitingQueue() async {
  List<WaitingList>? w_patients = await Controller.getWaitingList();
  if (w_patients!.isEmpty) {
    print('''
      De momento no hay nadie en lista de espera.
    ''');
  } else {
    int number_patient_in_list = w_patients.length;
    print('Ahora mismo hay $number_patient_in_list pacientes esperando');
    for (var i = 0; i < w_patients.length; i++) {
      WaitingList w_list = w_patients.elementAt(i);
      Patient? p_temp = await Controller.getPatientByID(w_list.id_patient!);

      print('''
  === Paciente ${i + 1} en la cola ===
  *** Datos  de paciente ***
  Nombre del paciente: ${p_temp!.name} ${p_temp.surnames}
  Historia de el paciente: ${p_temp.history_number}
  Sintomas del paciente: ${p_temp.sympton}
      ''');
    }
  }
}

Future<void> releaseConsultByID(int consult_id) async {
  List<Consult>? list_consult = await Controller.getConsults();
  String id_consult = list_consult!.elementAt((consult_id - 1)).id!;

  //Indico primero la id de la consulta que voy a liberar
  if (await Controller.releaseConsult(id_consult)) {
    //Si todo esta bien procedo a comprobar si tengo un paciente en lista de espera
    List<WaitingList>? waiting_list = await Controller.getWaitingList();
    if (waiting_list!.isEmpty) {
      //Si no hay nadie en lista, solo se libero la consulta
      print('Consulta liberada con exito');
    } else {
      /** Si hay alguien en lista, libero esta lista de espera la cual devolvera la nueva consulta procesada
       * con el paciente que estaba en la lista de espera
       */
      Consult? consult_processed =
          await Controller.releaseWaitingList(waiting_list, id_consult);

      //Debemos de comprobar que si no es null, de esta forma sabemos que se libero correctamente y pintamos los datos.
      if (consult_processed != null) {
        String? patient_name =
            await Controller.getPatientByID(consult_processed.id_patient!)
                .then((value) => '${value?.name} ${value?.surnames}');
        int number_consult = list_consult.indexWhere(
            (consult_list) => consult_list.id == consult_processed.id);

        String? doctor_name =
            await Controller.getDoctorByID(consult_processed.id_doctor!)
                .then((value) => '${value?.name}');

        print('''
        El paciente: $patient_name ya puede pasar
        Se le ha asignado la consulta ${number_consult + 1} ya puede pasar
        Le atenderá D. $doctor_name
        ''');
      } else {
        print('El valor de la consulta devuelta es null');
      }
    }
  } else {
    print('No se pudo liberar la consulta.');
  }
}

Future<int> admisionCliente() async {
  String? dni, name, surnames, sympton;

  stdout.write('Introduce tu dni:');
  dni = stdin.readLineSync();

  stdout.write('Introduce tu nombre:');
  name = stdin.readLineSync();

  stdout.write('Introduce tus apellidos:');
  surnames = stdin.readLineSync();

  stdout.write('Introduce tus síntomas:');
  sympton = stdin.readLineSync();

  return await Controller.addPatient(Patient(
      dni: dni,
      name: name,
      surnames: surnames,
      sympton: sympton,
      history_number: await Controller.getHistoryNumber()));
}

Future<void> showConsults() async {
  List<Consult>? consults = await Controller.getConsults();
  if (consults != null) {
    for (var i = 0; i < consults.length; i++) {
      Consult c = consults.elementAt(i);
      Doctor? d = await Controller.getDoctorByID(c.id_doctor!);
      Patient? p = await Controller.getPatientByID(c.id_patient!);
      if (c.isBusy!) {
        print('''
******Consulta: ${i + 1}******
Nombre de el médico:${d!.name}
Especialidad: ${d.specialty}
Paciente: ${p!.name} ${p.surnames}
Num_historia: ${p.history_number}
      ''');
      } else
        print('''
******Consulta: ${i + 1}******
Consulta libre
      ''');
    }
  } else {
    print('Consultas no disponibles');
  }
}

Future<bool> showBusyConsults() async {
  List<Consult>? consults = await Controller.getConsults();
  List<Consult>? busy_consults =
      consults?.where((consult) => consult.isBusy!).toList();
  if (!busy_consults!.isEmpty) {
    for (var i = 0; i < busy_consults.length; i++) {
      Consult c = busy_consults.elementAt(i);
      Doctor? d = await Controller.getDoctorByID(c.id_doctor!);
      Patient? p = await Controller.getPatientByID(c.id_patient!);

      print('''
******Consulta: ${i + 1}******
Nombre de el médico:${d!.name}
Especialidad: ${d.specialty}
Paciente: ${p!.name} ${p.surnames}
Num_historia: ${p.history_number}
      ''');
    }
    return true;
  } else {
    print('No hay consultas por liberar');
    return false;
  }
}

int lectorInt() {
  return int.parse(stdin.readLineSync() as String);
}
