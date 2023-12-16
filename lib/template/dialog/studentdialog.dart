import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/student.dart';
import 'package:tp70/services/studentservice.dart';

import '../../entities/classe.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class AddStudentDialog extends StatefulWidget {
  final Function()? notifyParent;
  Student? student;

  Classe? selectedClasse;

  AddStudentDialog(
      {super.key,
      @required this.notifyParent,
      this.student,
      this.selectedClasse});
  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  TextEditingController nomCtrl = TextEditingController();

  TextEditingController prenomCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();
  TextEditingController dateNaisCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String title = "Add Etudiant";
  bool modif = false;
  late int idStudent;
  Classe? selectedClass;
  List<Classe> classes = [];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        dateCtrl.text =
            DateFormat("yyyy-MM-dd").format(DateTime.parse(picked.toString()));
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedClass = widget.selectedClasse;
    print("selected class: ${selectedClass}");
    getAllClasses().then((result) {
      setState(() {
        classes = result;
      });
    });

    if (widget.student != null) {
      modif = true;
      title = "Update Etudiant";
      nomCtrl.text = widget.student!.nom;
      prenomCtrl.text = widget.student!.prenom;
      dateCtrl.text = DateFormat("yyyy-MM-dd")
          .format(DateTime.parse(widget.student!.dateNais.toString()));

      idStudent = widget.student!.id!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(title),
            TextFormField(
              controller: nomCtrl,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "...";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextFormField(
              controller: prenomCtrl,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "....";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "FirstName"),
            ),
            TextFormField(
              controller: dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Date"),
              onTap: () {
                _selectDate(context);
              },
            ),
            DropdownButtonFormField<Classe>(
              value: selectedClass,
              onChanged: (Classe? value) {
                setState(() {
                  selectedClass = value;
                });
              },
              items: classes.map((Classe classe) {
                return DropdownMenuItem<Classe>(
                  value: classe,
                  child: Text(classe.nomClass),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: "Class"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (modif == false) {
                  await addStudent(Student(
                    dateNais: selectedDate.toString(),
                    nom: nomCtrl.text,
                    prenom: prenomCtrl.text,
                    classe: selectedClass,
                  ));
                  widget.notifyParent!();
                } else {
                  await updateStudent(Student(
                    dateNais: selectedDate.toString(),
                    nom: nomCtrl.text,
                    prenom: prenomCtrl.text,
                    classe: selectedClass,
                    id: idStudent,
                  ));
                  widget.notifyParent!();
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Classe>> getAllClasses() async {
  Response response =
      await http.get(Uri.parse("http://localhost:8089/class/all"));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);

    // Assuming data is a list of classes
    List<Classe> classes = data.map((json) => Classe.fromJson(json)).toList();

    return classes;
  } else {
    // If the request was not successful, throw an exception or handle the error.
    throw Exception("Failed to load classes");
  }
}
