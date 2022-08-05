import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  _SecondRoute createState() => _SecondRoute();
}

class _SecondRoute extends State<SecondRoute> {
  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('preferencias');
  String dropdownvalue = "sin azucar";
  double valor = 2;
  String _id = "";
  String _name = "";

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  // Loading counter value on start
  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = (prefs.getString('ID') ?? "");
      dropdownvalue = (prefs.getString('cucharadas') ?? "");
      valor = double.parse((prefs.getString('cafe') ?? ""));
      _name = (prefs.getString('name') ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Preferencias Cafe'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          SizedBox(height: 20.0), //
          Text(_name, style: TextStyle(fontSize: 20)),
          DropdownButton(
            // Initial Value
            value: dropdownvalue,
            isExpanded: false,
            // Down Arrow Icon
            icon: const Icon(Icons.keyboard_arrow_down),

            // Array list of items
            items: [
              'sin azucar',
              'con 1 de azucar',
              'con 2 de azucar',
              'con 3 de azucar',
              'con 1 de Stevia',
              'con 2 de Stevia',
              'con 3 de Stevia',
            ].map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (String? newValue) {
              setState(() {
                dropdownvalue = newValue!;
              });
            },
          ),
          Slider(
            min: 0,
            max: 100,
            value: valor,
            onChanged: (value) {
              setState(() {
                valor = value;
              });
            },
          ),
          valor > 0 && valor < 33
              ? Text("NEGRO")
              : valor >= 33 && valor < 66
                  ? Text("TETERO")
                  : valor >= 66 && valor <= 100
                      ? Text("CON LECHE")
                      : Text("NADA"),
          const SizedBox(
            height: 70,
          ),
          ElevatedButton(
            onPressed: () async {
              await _productss
                  .doc(_id)
                  .update({"cafe": valor, "cucharadas": dropdownvalue});
              Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const HomePage()),
                ModalRoute.withName('/home'),
              );
            },
            child: const Text('Update!'),
          ),
          Text(""),
        ]),
      ),
    );
  }
}
