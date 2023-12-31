import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:tp70/entities/absence.dart';
import 'package:tp70/entities/student.dart';
import 'package:tp70/services/classeservice.dart';
import 'package:tp70/template/dialog/absencedialog.dart';
import 'package:tp70/template/navbar.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import '../entities/classe.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  AbsenceScreenState createState() => AbsenceScreenState();
}

class AbsenceScreenState extends State<AbsenceScreen> {
  List<Classe> classes = [];
  List<Student> students = [];
  Classe? selectedClass;
  Student? selectedStudent;
  List<Absence>? absences;

  @override
  void initState() {
    super.initState();
    // Fetch classes when the screen loads
    getAllClasses().then((result) {
      print("success getting all classes from absence screen");
      setState(() {
        classes = result;
      });

      print("class from absencescreen: " +
          classes.elementAt(0).matieres.toString());
    });
  }

  refresh() {
    setState(() {});
  }

  Future<void> getStudentsByClass(Classe selectedClass) async {
    Response response = await http.get(Uri.parse(
        "http://localhost:8089/etudiant/getByClasseId/${selectedClass.codClass}"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Student> studentsInClass =
          data.map((json) => Student.fromJson(json)).toList();
      setState(() {
        students = studentsInClass;
      });
    } else {
      throw Exception("Failed to load students");
    }
  }

  Future<void> getAbsenceByStudentId() async {
    Response response = await http.get(Uri.parse(
        "http://localhost:8089/absence/getByEtudiantId/${this.selectedStudent?.id}"));
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
                  getStudentsByClass(selectedClass!);
                }
              });
            },
            items: classes.map((Classe classe) {
              return DropdownMenuItem<Classe>(
                value: classe,
                child: Text(classe.nomClass),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: "Select a Class"),
          ),
          DropdownButtonFormField<Student>(
            value: selectedStudent,
            onChanged: (Student? value) {
              setState(() {
                selectedStudent = value;
              });

              // Fetch students absence
              getAbsenceByStudentId();
            },
            items: students.map((Student student) {
              return DropdownMenuItem<Student>(
                value: student,
                child: Text(student.nom),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: "Select a Student"),
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
                    motion: ScrollMotion(),
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
                                  "Student name: ",
                                ),
                                Text(
                                  "${absences!.elementAt(index).etudiant?.nom} ${absences!.elementAt(index).etudiant?.prenom}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Hours number: "),
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
                                const Text("Matiere name: "),
                                Text(
                                    absences
                                            ?.elementAt(index)
                                            .matiere
                                            ?.matiereName ??
                                        'N/A',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        backgroundColor:
                                            const Color.fromARGB(255, 68, 255, 224)))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              // show whene selected student is null
              return Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: const Text("Select a student!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        backgroundColor: const Color.fromARGB(255, 68, 255, 224))),
              );
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 68, 255, 224),
        onPressed: () async {
  print("FloatingActionButton clicked");
  print("Selected Class: $selectedClass");
  // Add other necessary checks
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
},

        child: const Icon(Icons.add),
      ),
    );
  }
}
