import 'package:flutter/material.dart';
import 'package:tp70/entities/formation.dart';
import 'package:tp70/services/formationservice.dart';

// ignore: must_be_immutable
class FormationDialog extends StatefulWidget {
  final Function()? notifyParent;
  Formation? formation;

  FormationDialog({super.key, @required this.notifyParent, this.formation});
  @override
  State<FormationDialog> createState() => _FormationDialogState();
}

class _FormationDialogState extends State<FormationDialog> {
  TextEditingController nomCtrl = TextEditingController();

  TextEditingController dureeCtrl = TextEditingController();

  String title = "Add Formation";
  bool modif = false;

  late int idFormation;

  @override
  void initState() {
    super.initState();
    if (widget.formation != null) {
      modif = true;
      title = "update Formation";
      nomCtrl.text = widget.formation!.nom;
      dureeCtrl.text = widget.formation!.duree.toString();
      idFormation = widget.formation!.id!;
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
                  return ".....";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "name"),
            ),
            TextFormField(
              controller: dureeCtrl,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return ".....";
                }
                return null;
              },
              decoration: const InputDecoration(labelText: "Period"),
            ),
            ElevatedButton(
                onPressed: () async {
                  if (modif == false) {
                    await addFormation(
                        Formation(int.parse(dureeCtrl.text), nomCtrl.text));
                  } else {
                    await updateFormation(Formation(
                        int.parse(dureeCtrl.text), nomCtrl.text, idFormation));
                  }
                  widget.notifyParent!();
                  Navigator.pop(context);
                },
                child: const Text("Add"))
          ],
        ),
      ),
    );
  }
}
