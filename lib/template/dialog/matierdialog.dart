import 'package:flutter/material.dart';
import 'package:tp70/entities/classe.dart';
import 'package:tp70/entities/matier.dart';
import 'package:tp70/services/classeservice.dart';

// ignore: must_be_immutable
class MatierDialog extends StatefulWidget {
  final Function()? notifyParent;
  Matier? matier;

  MatierDialog({super.key, @required this.notifyParent, this.matier});
  @override
  State<MatierDialog> createState() => _MatierDialogState();
}

class _MatierDialogState extends State<MatierDialog> {
  TextEditingController nameMat = TextEditingController();
  TextEditingController coefMat = TextEditingController();
  Classe? selectedClass;
  List<Classe> classes = [];

  String title = "Add Matier";
  bool modif = false;

  late int idMatier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllClasses().then((result) {
      // Check if the result is a List<Classe> before assigning
      setState(() {
        classes = result;
      });
    });

    if (widget.matier != null) {
      modif = true;
      title = "Update matier";
      nameMat.text = (widget.matier!.matiereName).toString();
      coefMat.text = (widget.matier!.matiereCoef).toString();
      idMatier = widget.matier!.matiereId!;
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
              controller: nameMat,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "....";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "name"),
            ),
            TextFormField(
              controller: coefMat,
              decoration: const InputDecoration(labelText: "coef"),
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
                    await addMatier(
                        Matier(nameMat.text, double.parse(coefMat.text)),
                        selectedClass!.codClass!);
                    widget.notifyParent!();
                  } else {
                    await updateMatier(Matier(
                        nameMat.text, double.parse(coefMat.text), idMatier));
                    widget.notifyParent!();
                  }
                  Navigator.pop(context);
                },
                child: const Text("Add"))
          ],
        ),
      ),
    );
  }
}
