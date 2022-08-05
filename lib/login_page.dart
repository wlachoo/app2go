import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* Screen*/
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('preferencias');

  var _password = "";
  var _email = "";
  var onError = false;

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
        title: Text("Login Page Flutter Firebase"),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  Image.network(
                      "https://res.cloudinary.com/dh5xyrna6/image/upload/v1659732652/iaqs8pzkan2nqtgfcdxz.webp",
                      width: 130.0,
                      height: 130.0),
                  SizedBox(height: 20.0), // <= NEW
                  Text(
                    'Login User',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20.0), // <= NEW
                  TextFormField(
                      onChanged: (value) => {
                            setState(() {
                              _email = value;
                            })
                          }, // <= NEW
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: "Email Address")),
                  TextFormField(
                      onChanged: (value) => {
                            setState(() {
                              _password = value;
                            })
                          },
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Password")),
                  SizedBox(height: 20.0), // <= NEW
                  onError
                      ? Positioned(
                          bottom: 0,
                          child: Text('password or email incorrect',
                              style: TextStyle(color: Colors.red)))
                      : Container(),
                  SizedBox(height: 20.0), // <= NEW
                  ElevatedButton(
                      child: Text("LOGIN"),
                      onPressed: () async {
                        final snapshot = await FirebaseFirestore.instance
                            .collection("preferencias")
                            .where("email", isEqualTo: _email)
                            .where("password", isEqualTo: _password)
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
                            print(doc.data());
                            Navigator.pushReplacementNamed(context, "/home");
                          });
                        } else {
                          setState(() {
                            onError = true;
                          });
                        }
                        //addID();
                        //Navigator.pushReplacementNamed(context, "/home");
                      }),
                  SizedBox(height: 50.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: new Text("Registrate",
                        style:
                            TextStyle(fontSize: 18, color: Colors.blue[400])),
                  )
                ],
              )))),
    );
  }
}
