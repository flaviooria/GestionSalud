import '../controller/controller.dart';
import '../providers/consult_provider.dart';

void main(List<String> args) async {
  var res = await Controller.getConsults();
  var consults = consultResponseProviderFromJson(res.body).consults;

  print(consults?[0].id_doctor);
}
