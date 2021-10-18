import 'dart:convert';
import 'package:http/http.dart' as http;

class Services {
  static Future<bool> post(
      Map<String, dynamic> parsedObject, String url) async {
    final endpoint = Uri.parse(url);
    final res = await http.post(endpoint, body: json.encode(parsedObject));
    return res.statusCode == 200;
  }

  static Future<http.Response> get(String url) async =>
      await http.get(Uri.parse(url));

  static Future<bool> delete(String url) async {
    http.Response res = await http.delete(Uri.parse(url));
    return res.statusCode == 200;
  }

  static Future<bool> put(Map<String, dynamic> parsedObject, String url) async {
    final endpoint = Uri.parse(url);
    http.Response res =
        await http.put(endpoint, body: jsonEncode(parsedObject));
    return res.statusCode == 200;
  }
}
