import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/absence.dart';
import 'package:tp70/entities/matier.dart';
import 'package:tp70/services/classeservice.dart';

// ignore: must_be_immutable
class AbsenceDialog extends StatefulWidget {
  final Function()? notifyParent;
  final Function()? getAllAbsence;
  Absence? absence;
  List<Matier>? matieres;
  bool? modif = false;

  AbsenceDialog(
      {super.key,
      @required this.notifyParent,
      this.getAllAbsence,
      this.matieres,
      this.absence,
      this.modif});
  @override
  State<AbsenceDialog> createState() => AbsenceDialogState();
}

class AbsenceDialogState extends State<AbsenceDialog> {
  TextEditingController nbhAbsence = TextEditingController();
  TextEditingController dateAbsence = TextEditingController();

  List<Matier>? matiers;
  Matier? selectedMatiere;

  Absence? absence;

  String title = "Add Absence";
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime =
          // ignore: use_build_context_synchronously
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formattedDateTime =
            DateFormat("yyyy-MM-ddTHH:mm:ss").format(pickedDateTime);

        setState(() {
          dateAbsence.text = formattedDateTime;
          selectedDate = pickedDateTime;
        });
      }
    }
  }

  late int? idAbsence;

  @override
  void initState() {
    matiers = widget.matieres;
    absence = widget.absence;
    if (kDebugMode) {
      print("${matiers.toString()}");
    }
    super.initState();

    if (widget.absence != null) {
      title = "Update Absence";
      nbhAbsence.text = (widget.absence?.absenceNb).toString();
      dateAbsence.text = (widget.absence?.date).toString();
      idAbsence = widget.absence?.absenceId;
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
              controller: nbhAbsence,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "....";
                }
                if (double.tryParse(value) == null) {
                  return "Enter a valid number";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: ""),
            ),
            TextFormField(
              controller: dateAbsence,
              readOnly: true,
              decoration: const InputDecoration(labelText: ""),
              onTap: () {
                _selectDate(context);
              },
            ),
            DropdownButtonFormField<Matier>(
              value: selectedMatiere,
              onChanged: (Matier? value) {
                setState(() {
                  selectedMatiere = value;
                });
              },
              items: matiers?.map((Matier matiere) {
                    return DropdownMenuItem<Matier>(
                      value: matiere,
                      child: Text(matiere.matiereName),
                    );
                  }).toList() ??
                  [],
              decoration: const InputDecoration(labelText: "Matier"),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (widget.modif == false) {
                    await addAbsence(Absence(
                            double.parse(nbhAbsence.text),
                            dateAbsence.text,
                            absence?.etudiant,
                            selectedMatiere,
                            absence?.absenceId))
                        .then((value) =>
                            {widget.getAllAbsence!(), widget.notifyParent!()});
                  } else {
                    await updateAbsence(Absence(
                            double.parse(nbhAbsence.text),
                            dateAbsence.text,
                            absence?.etudiant,
                            selectedMatiere,
                            absence?.absenceId))
                        .then((value) =>
                            {widget.getAllAbsence!(), widget.notifyParent!()});
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Text("Add"))
          ],
        ),
      ),
    );
  }
}
