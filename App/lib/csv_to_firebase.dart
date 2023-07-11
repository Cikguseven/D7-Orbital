/// From CSV files, parse it and upload the data to firebase collection 'food_data_technoedge'
///
/// 1) Parse CSV file, get the fields from the 1st row headers
/// 2) For each line, make a json with the field attributes
/// 3) Submit this json

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'utils.dart';

class CSVUploadWidget extends StatefulWidget {
  const CSVUploadWidget({Key? key}) : super(key: key);

  @override
  State<CSVUploadWidget> createState() => _CSVUploadWidgetState();
}

class _CSVUploadWidgetState extends State<CSVUploadWidget> {
  final foodDBKeyController = TextEditingController();
  List<List<String>> _csvData = [];

  FilePickerResult? selectedFiles;
  String selectedFileName = '';
  int selectedFileIdx = -1;

  void parseCSVToTable() {
    const csvParser = CsvToListConverter(shouldParseNumbers: false);
    setState(() {
      _csvData = csvParser.convert(
          utf8.decode(selectedFiles!.files[selectedFileIdx].bytes!.toList()));
    });
  }

  Future<void> getFile() async {
    final FilePicker picker = FilePicker.platform;
    // FilePickerResult? selectedFiles;

    selectedFiles = await picker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (selectedFiles == null) {
      Utils.showSnackBar('No file selected');
      return;
    }

    if (selectedFiles!.files.any((file) => file.bytes == null)) {
      Utils.showSnackBar('One or more files are empty.');
      return;
    }

    setState(() {
      for (List<String> line in _csvData) {}
      selectedFileIdx = 0;
      selectedFileName = selectedFiles!.files.first.name;
      parseCSVToTable();
    });
  }

  @override
  void dispose() {
    foodDBKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload food data CSV'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Prefix of database',
                  ),
                  controller: foodDBKeyController,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Preview of CSV file',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: Colors.blueAccent,
                    onPressed: selectedFileIdx == -1 || selectedFileIdx == 0
                        ? null
                        : () {
                            setState(() {
                              selectedFileIdx--;
                              selectedFileName =
                                  selectedFiles!.files[selectedFileIdx].name;
                              parseCSVToTable();
                            });
                          },
                  ),
                  title: Center(
                    child: Text(selectedFileName),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: Colors.blueAccent,
                    onPressed: selectedFileIdx == -1 ||
                            selectedFileIdx == selectedFiles!.count - 1
                        ? null
                        : () {
                            setState(() {
                              selectedFileIdx++;
                              selectedFileName =
                                  selectedFiles!.files[selectedFileIdx].name;
                              parseCSVToTable();
                            });
                          },
                  ),
                ),

                /// Preview of HEAD
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _csvData.isEmpty
                      ? SizedBox(
                          // Just setting the height to be same as displayed table
                          height: () {
                            return kMinInteractiveDimension * 5 + 56.0;
                            // const dttd = DataTableThemeData();
                            // return dttd.dataRowHeight! * 5 + dttd.headingRowHeight!;
                          }(),
                        )
                      : DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              // This is just stupid
                              (states) => Colors.blueGrey),
                          columns: _csvData[0]
                              .map(
                                (item) => DataColumn(
                                  label: Text(
                                    item.toString(),
                                  ),
                                ),
                              )
                              .toList(),
                          rows: _csvData
                              .getRange(1, min(_csvData.length, 6))
                              .map(
                                (csvRow) => DataRow(
                                  cells: csvRow
                                      .map(
                                        (csvItem) => DataCell(
                                          Text(
                                            csvItem.toString(),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                ),

                IconButton(
                    onPressed: () {
                      getFile();
                    },
                    icon: const Icon(Icons.insert_drive_file)),
                ElevatedButton.icon(
                    onPressed: uploadToFirebaseCallback,
                    icon: const Icon(Icons.upload_file_rounded, size: 24),
                    label: const Text(
                      'Upload to database',
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future uploadToFirebaseCallback() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      String foodDBCollectionPrefix = foodDBKeyController.text.trim();

      if (selectedFiles == null) throw ArgumentError('No file selected');

      if (foodDBCollectionPrefix.isEmpty) {
        throw ArgumentError('Please specify database prefix');
      }

      final suffix = selectedFileName
          .toLowerCase()
          .replaceAll(' ', '_')
          .substring(0, selectedFileName.length - 4); // remove csv extension
      final db = FirebaseFirestore.instance
          .collection('${foodDBCollectionPrefix}_$suffix');
      final snapshot = await db.get();
      if (snapshot.size != 0) {
        throw ArgumentError('Database of that name already exists!');
      }

      final headers = _csvData[0];
      final numFields = headers.length;
      Map<String, dynamic> toUpload = Map.fromIterable(_csvData[0]);
      for (int i = 1; i < _csvData.length; i++) {
        for (int j = 0; j < numFields; j++) {
          toUpload[headers[j]] = _csvData[i][j];
        }
        // print(toUpload);
        // print(toUpload[headers[0]]);
        // if (i == 5) break;
        await db
            .doc(toUpload[headers[0]].replaceAll('/',
                '')) // Name of the dish as Doc ID. NOTE: Cannot have forward slash!
            .set(toUpload);
      }
      Utils.showSnackBar(
          'Successfully added database with name ${'${foodDBCollectionPrefix}_$suffix'}',
          isBad: false);
    } on ArgumentError {
      Utils.showSnackBar('Unable to add to database');
    } on Exception catch (e) {
      Utils.showSnackBar('$e\n Cancelled upload');
      // final collection = FirebaseFirestore.instance
      //     .collection(foodDBKeyController.text.trim());
      // final snapshots = await collection.get();
      // for (final doc in snapshots.docs) {
      //   await doc.reference.delete();
      // }
    } finally {
      Navigator.pop(context);
    }
  }
}
