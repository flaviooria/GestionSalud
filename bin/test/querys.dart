import '../controller/controller.dart';

void main(List<String> args) async {
  var res = await Controller.getWaitingList();

  print(res);
}
