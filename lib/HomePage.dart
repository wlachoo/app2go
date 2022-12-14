import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'SecondRoute.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('preferencias');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final double? price =
                        double.tryParse(_priceController.text);
                    if (name != null && price != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _productss.add({"name": name, "price": price});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _productss
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "price": price});
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _priceController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _productss.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Cafes de Apps2Go'),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 1,
                child: Text("Settings"),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text("Logout"),
              ),
            ];
          }, onSelected: (value) async {
            if (value == 0) {
              print("My account menu is selected.");
            } else if (value == 1) {
              print("Settings menu is selected.");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondRoute()),
              );
            } else if (value == 2) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              final id = await prefs.remove('ID');
              final cafe = await prefs.remove('cafe');
              final cucharadas = await prefs.remove('cucharadas');
              final name = await prefs.remove('name');
              Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => const LoginPage()),
                ModalRoute.withName('/login'),
              );
            }
          }),
        ],
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _productss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  /*margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),*/
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Row(children: [
                    Image.network(
                      documentSnapshot['cafe'] > 0 &&
                              documentSnapshot['cafe'] < 33
                          ? 'https://res.cloudinary.com/dh5xyrna6/image/upload/v1659629549/ze3d0hkksrtmu9geinvd.png'
                          : documentSnapshot['cafe'] >= 33 &&
                                  documentSnapshot['cafe'] < 66
                              ? 'https://res.cloudinary.com/dh5xyrna6/image/upload/v1659629549/yhqtf916pkonaatlmuia.png'
                              : documentSnapshot['cafe'] >= 66 &&
                                      documentSnapshot['cafe'] <= 100
                                  ? 'https://res.cloudinary.com/dh5xyrna6/image/upload/v1659629548/ydihiawpuywspwxvhwro.png'
                                  : 'https://res.cloudinary.com/dh5xyrna6/image/upload/v1659629548/ydihiawpuywspwxvhwro.png',
                      fit: BoxFit.fill,
                      width: 200,
                    ),
                    SizedBox(width: 20.0),
                    Column(children: <Widget>[
                      Text(documentSnapshot['name']),
                      Text(
                        documentSnapshot['cucharadas'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ])
                  ]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      /*floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),*/
    );
  }
}
