import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  String dropdownvalue = "sin azucar";
  double valor = 2;

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('preferencias');

  // Obtain shared preferences.
  addID(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ID', id);
  }

  addCafe(String cafe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cafe', cafe);
  }

  addName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
  }

  addCucharadas(String cucharadas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cucharadas', cucharadas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0), // <= NEW
                  Text(
                    'Register User',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20.0), // <= NEW
                  TextFormField(
                      //onSaved: (value) => {print(value)}, // <= NEW
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: "Email Address")),
                  TextFormField(
                      //onSaved: (value) => _password = value ?? '',
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Password")),
                  SizedBox(height: 20.0), // <= NEW
                  TextFormField(
                      //onSaved: (value) => _name = value ?? '',
                      controller: _name,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Name")),
                  SizedBox(height: 20.0),
                  DropdownButton(
                    // Initial Value
                    value: dropdownvalue,
                    isExpanded: true,
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
                  SizedBox(height: 20.0),
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
                  SizedBox(height: 30.0),
                  ElevatedButton(
                      child: Text("REGISTER"),
                      onPressed: () async {
                        final String? name = _name.text;
                        final String? email = _email.text;
                        final String? password = _password.text;

                        if (name != null &&
                            email != null &&
                            password != null &&
                            valor != null &&
                            dropdownvalue != null) {
                          await _productss.add({
                            "name": name,
                            "email": email,
                            "password": password,
                            "cafe": valor,
                            "cucharadas": dropdownvalue
                          });
                        }

                        // Clear the text fields
                        _name.text = '';
                        _email.text = '';
                        _password.text = '';
                        valor = 2;
                        dropdownvalue = 'Item 1';

                        final snapshot = await FirebaseFirestore.instance
                            .collection("preferencias")
                            .where("email", isEqualTo: email)
                            .get();
                        if (snapshot.docs.isNotEmpty) {
                          snapshot.docs.forEach((doc) {
                            addID(doc.id);
                            var decoded = doc.data();
                            decoded.forEach((k, v) => {
                                  //print('${k}: ${v}')
                                  if ("cafe" == k)
                                    {addCafe(v.toString())}
                                  else if ("cucharadas" == k)
                                    {addCucharadas(v)}
                                  else if ("name" == k)
                                    {addName(v)}
                                });
                            //Navigator.pop(context, "/home");
                            Navigator.pushAndRemoveUntil<void>(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const HomePage()),
                              ModalRoute.withName('/home'),
                            );
                          });
                        }
                      }),
                  SizedBox(height: 50.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: new Text("Login",
                        style:
                            TextStyle(fontSize: 18, color: Colors.blue[400])),
                  )
                ],
              )))),
    );
  }
}
