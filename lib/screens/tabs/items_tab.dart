import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_waste_web/services/add_item.dart';
import 'package:smart_waste_web/widgets/button_widget.dart';
import 'package:smart_waste_web/widgets/text_widget.dart';
import 'package:smart_waste_web/widgets/textfield_widget.dart';
import 'package:smart_waste_web/widgets/toast_widget.dart';

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  final name = TextEditingController();
  final pts = TextEditingController();

  void showEditDialog(String itemId, String currentName, int currentPts) {
    name.text = currentName;
    pts.text = currentPts.toString();

    showDialog(
      context: context,
      builder: (context) {
        return EditItemDialog(
          name: name,
          pts: pts,
          itemId: itemId,
        );
      },
    );
  }

  void showAddDialog() {
    name.clear();
    pts.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(
          name: name,
          pts: pts,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: ButtonWidget(
              color: const Color.fromARGB(255, 33, 243, 114),
              height: 45,
              width: 150,
              label: 'Add Item',
              onPressed: showAddDialog,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Items').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.black)),
                );
              }

              final data = snapshot.requireData;
              return DataTable(
                showCheckboxColumn: false,
                border: TableBorder.all(),
                columnSpacing: 125,
                columns: [
                  DataColumn(
                    label: TextWidget(
                        text: 'Item Number', fontSize: 18, fontFamily: 'Bold'),
                  ),
                  DataColumn(
                    label: TextWidget(
                        text: 'Money', fontSize: 18, fontFamily: 'Bold'),
                  ),
                  DataColumn(
                    label: TextWidget(
                        text: 'Equivalent Points',
                        fontSize: 18,
                        fontFamily: 'Bold'),
                  ),
                  DataColumn(
                    label: TextWidget(
                        text: 'Quantity', fontSize: 18, fontFamily: 'Bold'),
                  ),
                  DataColumn(
                    label: TextWidget(
                        text: 'Actions', fontSize: 18, fontFamily: 'Bold'),
                  ),
                ],
                rows: [
                  for (int i = 0; i < data.docs.length; i++)
                    DataRow(
                      color: WidgetStateColor.resolveWith((states) =>
                          i % 2 == 0 ? Colors.white : Colors.grey[200]!),
                      cells: [
                        DataCell(
                          TextWidget(
                              text: '${i + 1}',
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: Colors.grey),
                        ),
                        DataCell(
                          TextWidget(
                              text: data.docs[i]['name'],
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: Colors.grey),
                        ),
                        DataCell(
                          TextWidget(
                              text: data.docs[i]['points'].toString(),
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: Colors.grey),
                        ),
                        DataCell(
                          TextWidget(
                              text: data.docs[i]['qty'].toString(),
                              fontSize: 14,
                              fontFamily: 'Medium',
                              color: Colors.grey),
                        ),
                        DataCell(
                          Row(
                            children: [
                              ButtonWidget(
                                color: const Color.fromARGB(206, 70, 228, 131),
                                height: 35,
                                width: 125,
                                label: 'Add',
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('Items')
                                        .doc(data.docs[i].id)
                                        .update({
                                      'qty': FieldValue.increment(1),
                                    });
                                  } catch (e) {
                                    showToast('Failed to add quantity.');
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              ButtonWidget(
                                color: const Color.fromARGB(206, 70, 228, 131),
                                height: 35,
                                width: 125,
                                label: 'Edit',
                                onPressed: () {
                                  showEditDialog(
                                      data.docs[i].id,
                                      data.docs[i]['name'],
                                      data.docs[i]['points']);
                                },
                              ),
                              const SizedBox(width: 10),
                              ButtonWidget(
                                color: Colors.red,
                                height: 35,
                                width: 125,
                                label: 'Delete',
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('Items')
                                        .doc(data.docs[i].id)
                                        .delete();
                                  } catch (e) {
                                    showToast('Failed to delete item.');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddItemDialog extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController pts;

  const AddItemDialog({super.key, required this.name, required this.pts});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFieldWidget(
                controller: name,
                label: 'Money:',
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                controller: pts,
                label: 'Equivalent Points:',
              ),
              const SizedBox(height: 10),
              ButtonWidget(
                color: const Color.fromARGB(255, 33, 243, 114),
                height: 45,
                width: 150,
                label: 'Add',
                onPressed: () {
                  if (name.text.isEmpty || pts.text.isEmpty) {
                    showToast('Please fill all fields.');
                    return;
                  }
                  try {
                    int points = int.parse(pts.text);
                    addItem(name.text, points);
                    showToast('Item added successfully!');
                    Navigator.pop(context);
                  } catch (e) {
                    showToast('Please enter valid points.');
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class EditItemDialog extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController pts;
  final String itemId;

  const EditItemDialog({
    super.key,
    required this.name,
    required this.pts,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFieldWidget(
                controller: name,
                label: 'Money:',
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                controller: pts,
                label: 'Equivalent Points:',
              ),
              const SizedBox(height: 10),
              ButtonWidget(
                color: const Color.fromARGB(255, 33, 243, 114),
                height: 45,
                width: 150,
                label: 'Update',
                onPressed: () async {
                  if (name.text.isEmpty || pts.text.isEmpty) {
                    showToast('Please fill all fields.');
                    return;
                  }
                  try {
                    int points = int.parse(pts.text);
                    await FirebaseFirestore.instance
                        .collection('Items')
                        .doc(itemId)
                        .update({
                      'name': name.text,
                      'points': points,
                    });
                    showToast('Item updated successfully!');
                    Navigator.pop(context);
                  } catch (e) {
                    showToast('Please enter valid points.');
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
