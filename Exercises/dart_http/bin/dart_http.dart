import 'package:http/http.dart' as http;
import 'dart:convert';

String url = 'https://jsonplaceholder.typicode.com/todos/1';
String url2 = "https://jsonplaceholder.typicode.com/posts";

void main() async {
  print("01: Start");
  Map data = await getData(url, 1);
  processData(data);
  print("04: First HTTP Done, Second HTTP Start");
  List data2 = await getData(url2, 2);
  processData(data2);
  print("07: Second HTTP Done");
}

dynamic getData(String url, int time) async {
  dynamic result;
  if(time == 1) print("02: Calling API");
  else print("05: Calling API");

  try {
    result = await http.get(Uri.parse(url));
  } on Exception catch (e) {
    print ("Error - Invalid URL!");
    print (e);
    if(time == 1) return {};
    else return [];
  }

  return jsonDecode(result.body);
}

void processData(dynamic data) {
  if(data is Map) print("03: Output Data");
  else print("06: Output Data");

  if(data is Map) print(data);
  else for(Map m in data) print (m['title']);
}