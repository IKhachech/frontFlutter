import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/absence.dart';
import 'package:tp70/entities/student.dart';
import 'package:tp70/services/classeservice.dart';
import 'package:tp70/entities/matier.dart';
import 'package:tp70/template/dialog/absencedialog.dart';
import 'package:tp70/template/navbar.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import '../entities/classe.dart';

class AbsenceMatScrenn extends StatefulWidget {
  const AbsenceMatScrenn({super.key});

  @override
  AbsenceMatScrennState createState() => AbsenceMatScrennState();
}

class AbsenceMatScrennState extends State<AbsenceMatScrenn> {
  List<Classe> classes = [];
  List<Student> students = [];
  Classe? selectedClass;
  Student? selectedStudent;
  List<Absence>? absences;

  List<Matier>? matiers;
  Matier? selectedMatiere;
  TextEditingController dateCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

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
        getAbsenceByMatiereAndDate();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllClasses().then((result) {
      if (kDebugMode) {
        print("success ");
      }
      setState(() {
        classes = result;
      });

      if (kDebugMode) {
        print(
          classes.elementAt(0).matieres.toString());
      }
    });
  }

  refresh() {
    setState(() {});
  }



  Future<void> getAbsenceByStudentId() async {
    Response response = await http.get(Uri.parse(
        "http://localhost:8089/absence/getByEtudiantId/${selectedStudent?.id}"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Absence> studentAbcenses =
          data.map((json) => Absence.fromJson(json)).toList();
      setState(() {
        absences = studentAbcenses;
      });
    } else {
      throw Exception("Failed to load absences");
    }
  }

  Future<void> getAbsenceByMatiereAndDate() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String url =
        "http://localhost:8089/absence/getByMatiereIdAndDate/?matiereId=${selectedMatiere?.matiereId.toString()}&date=$formattedDate";
    print(url);
    Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Absence> matiereDateAbsences =
          data.map((json) => Absence.fromJson(json)).toList();

      setState(() {
        absences = matiereDateAbsences;
      });
    } else {
      throw Exception("Failed to load absences");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('Absences'),
      body: Column(
        children: [
          DropdownButtonFormField<Classe>(
            value: selectedClass,
            onChanged: (Classe? value) {
              setState(() {
                selectedStudent = null;
                absences = null;
                selectedClass = value;
                if (selectedClass != null) {
                }
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
          DropdownButtonFormField<Matier>(
            value: selectedMatiere,
            onChanged: (Matier? value) {
              setState(() {
                selectedMatiere = value;
              });
            },
            items: selectedClass?.matieres?.map((Matier matiere) {
              return DropdownMenuItem<Matier>(
                value: matiere,
                child: Text(matiere.matiereName),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: "Matier"),
          ),
          TextFormField(
            controller: dateCtrl,
            readOnly: true,
            decoration: const InputDecoration(labelText: "Date"),
            onTap: () {
              _selectDate(context);
            },
          ),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: absences?.length ?? 1,
            itemBuilder: (BuildContext context, int index) {
              if (absences != null) {
                return Slidable(
                  key: Key(absences!.elementAt(index).absenceId.toString()),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AbsenceDialog(
                                  notifyParent: refresh,
                                  getAllAbsence: getAbsenceByStudentId,
                                  matieres: selectedClass?.matieres,
                                  absence: Absence(
                                      absences?.elementAt(index).absenceNb,
                                      absences?.elementAt(index).date,
                                      selectedStudent,
                                      absences?.elementAt(index).matiere,
                                      absences?.elementAt(index).absenceId),
                                  modif: true,
                                );
                              });
                        },
                        backgroundColor: const Color.fromARGB(255, 68, 255, 224),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () async {
                      deleteAbsence(absences?.elementAt(index).absenceId);
                      getAbsenceByStudentId();
                    }),
                    children: [Container()],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Student: ",
                                ),
                                Text(
                                  "${absences!.elementAt(index).etudiant?.nom ?? 'N/A'} ${absences!.elementAt(index).etudiant?.prenom ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Hour: "),
                                Text(
                                  absences!
                                      .elementAt(index)
                                      .absenceNb
                                      .toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2.0,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Matier: "),
                                Text(
                                    absences
                                            ?.elementAt(index)
                                            .matiere
                                            ?.matiereName ??
                                        'N/A',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        backgroundColor:
                                            Color.fromARGB(255, 68, 255, 224)))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: const Text("test avec DSI31/FLUTTER le 11/12 ou 3/12 exist deja dans la base",
                    textAlign: TextAlign.center,
                ),
              );
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 68, 255, 224),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AbsenceDialog(
                  notifyParent: refresh,
                  getAllAbsence: getAbsenceByStudentId,
                  matieres: selectedClass?.matieres,
                  absence: Absence(0, "", selectedStudent, null, null),
                  modif: false,
                );
              });
          //print("test");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}