import 'dart:typed_data'; // Import for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_waste_web/widgets/text_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RecordsTab extends StatefulWidget {
  const RecordsTab({super.key});

  @override
  _RecordsTabState createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  String searchQuery = '';
  String? selectedMonth;
  List<QueryDocumentSnapshot> filteredDocs = []; // Define filteredDocs

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search by User Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            hint: Text('Select Month'),
            value: selectedMonth,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text('Reset'),
              ),
              DropdownMenuItem(
                value: '01',
                child: Text('January'),
              ),
              DropdownMenuItem(
                value: '02',
                child: Text('February'),
              ),
              DropdownMenuItem(
                value: '03',
                child: Text('March'),
              ),
              DropdownMenuItem(
                value: '04',
                child: Text('April'),
              ),
              DropdownMenuItem(
                value: '05',
                child: Text('May'),
              ),
              DropdownMenuItem(
                value: '06',
                child: Text('June'),
              ),
              DropdownMenuItem(
                value: '07',
                child: Text('July'),
              ),
              DropdownMenuItem(
                value: '08',
                child: Text('August'),
              ),
              DropdownMenuItem(
                value: '09',
                child: Text('September'),
              ),
              DropdownMenuItem(
                value: '10',
                child: Text('October'),
              ),
              DropdownMenuItem(
                value: '11',
                child: Text('November'),
              ),
              DropdownMenuItem(
                value: '12',
                child: Text('December'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedMonth = value;
              });
            },
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final pdf = await _generatePdf(filteredDocs);
            await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdf);
          },
          child: Text('Download Report'),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Records').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Error'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(child: Text('No Data'));
              }

              filteredDocs = data.docs.where((doc) {
                final record = doc.data() as Map<String, dynamic>;
                final name = record['myname']?.toString().toLowerCase() ?? '';
                final timestamp = record['dateTime'] as Timestamp;
                final date = timestamp.toDate();
                final monthMatches = selectedMonth == null ||
                    date.month.toString().padLeft(2, '0') == selectedMonth;
                return name.contains(searchQuery.toLowerCase()) && monthMatches;
              }).toList();

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 50),
                    child: DataTable(
                      showCheckboxColumn: false,
                      border: TableBorder.all(),
                      columnSpacing: 100,
                      columns: [
                        DataColumn(
                          label: TextWidget(
                            text: 'ID Number',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Name',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Item Name',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Equivalent Points',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                        DataColumn(
                          label: TextWidget(
                            text: 'Date & Time',
                            fontSize: 18,
                            fontFamily: 'Bold',
                          ),
                        ),
                      ],
                      rows: [
                        for (int i = 0; i < filteredDocs.length; i++)
                          DataRow(
                            color: MaterialStateColor.resolveWith(
                              (states) =>
                                  i % 2 == 0 ? Colors.white : Colors.grey[200]!,
                            ),
                            cells: [
                              DataCell(
                                TextWidget(
                                  text: '${i + 1}',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.grey,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text: (filteredDocs[i].data()
                                          as Map<String, dynamic>)['myname'] ??
                                      'N/A',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.grey,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text: (filteredDocs[i].data()
                                          as Map<String, dynamic>)['name'] ??
                                      'N/A',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.grey,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text:
                                      '${(filteredDocs[i].data() as Map<String, dynamic>)['pts']?.toString() ?? 'N/A'} pts',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.grey,
                                ),
                              ),
                              DataCell(
                                TextWidget(
                                  text: (filteredDocs[i].data() as Map<String,
                                              dynamic>?)?['dateTime'] !=
                                          null
                                      ? _formatDate((filteredDocs[i].data()
                                          as Map<String, dynamic>)['dateTime'])
                                      : 'N/A',
                                  fontSize: 14,
                                  fontFamily: 'Medium',
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$formattedDate $formattedTime';
  }

  Future<Uint8List> _generatePdf(List<QueryDocumentSnapshot> records) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: <String>[
              'ID Number',
              'Name',
              'Item Name',
              'Equivalent Points',
              'Date & Time'
            ],
            data: <List<String>>[
              for (var record in records)
                [
                  '${records.indexOf(record) + 1}',
                  (record.data() as Map<String, dynamic>)['myname'] ?? 'N/A',
                  (record.data() as Map<String, dynamic>)['name'] ?? 'N/A',
                  (record.data() as Map<String, dynamic>)['pts']?.toString() ??
                      '0',
                  _formatDate(record.data() as Timestamp)
                ],
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}
