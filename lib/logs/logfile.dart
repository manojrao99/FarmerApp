import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Log {
  Future<void> saveResponseToFile(String response) async {
    // Get the documents directory (emulator's documents directory)
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Get the current directory (project directory)
    String currentDirectory = dirname(documentsDirectory.path);

    // Create a File object in the project directory
    final File file = File('$currentDirectory/api_response.txt');
    print("file path ${file.path}");

    // Open the file in write mode
    IOSink sink = file.openWrite(mode: FileMode.write);

    // Write the response to the file
    sink.write(response);

    // Close the file
    await sink.close();
  }
}