void main() async {
  print("Start");
  String? data = await getData();
  processData(data);
  print("End");
}

Future<String?> getData() async {
  String? result;

  await Future.delayed(Duration(seconds: 2), () {
    result = "Data came back from task.";
    print("> I have Data!");
  });

  return result;
}

void processData(String? data) {
  print(">> Process Data, $data");
}