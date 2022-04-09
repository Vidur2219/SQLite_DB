import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sqlite_database_app/helpers/db_helper.dart';
import 'package:sqlite_database_app/models/student_model.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String? name;
  String? city;
  String? age;

  var value;

  late Future<List<Student>> fetchdata;

  final ImagePicker _picker = ImagePicker();
  Uint8List? img;

  @override
  void initState() {
    super.initState();
    fetchdata = DBHelper.dbHelper.fetchAllData();
    checkDB();
  }

  checkDB() async {
    await DBHelper.dbHelper.initDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,
        elevation: 0,
        title: const Text(
          "SQLite Database",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              child: TextField(
                onChanged: (val) {
                  Future<List<Student>> response =
                      DBHelper.dbHelper.fetchSearchedData(val);
                  setState(() {
                    fetchdata = response;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search by name...",
                ),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: FutureBuilder(
              future: fetchdata,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  List<Student> data = snapshot.data;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          leading: Text("${data[i].id}"),
                          title: Text(data[i].name),
                          isThreeLine: true,
                          subtitle: Text(
                              "City: ${data[i].city} \nAge: ${data[i].age}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: AlertDialog(
                                          title: const Text(
                                              "Enter Your Information"),
                                          content: Form(
                                            key: globalKey,
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  controller: nameController,
                                                  textInputAction: TextInputAction.next,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    hintText: "Enter Your Name",
                                                  ),
                                                  validator: (val) {
                                                    if (val!.isEmpty) {
                                                      return "Please Enter Name";
                                                    }
                                                  },
                                                  onSaved: (val) {
                                                    setState(() {
                                                      name = val!;
                                                    });
                                                  },
                                                ),
                                                TextFormField(
                                                  controller: cityController,
                                                  textInputAction: TextInputAction.next,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    hintText: "Enter Your City",
                                                  ),
                                                  validator: (val) {
                                                    if (val!.isEmpty) {
                                                      return "Please Enter City";
                                                    }
                                                  },
                                                  onSaved: (val) {
                                                    setState(() {
                                                      city = val!;
                                                    });
                                                  },
                                                ),
                                                TextFormField(
                                                  controller: ageController,
                                                  textInputAction: TextInputAction.done,
                                                  keyboardType: TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    hintText: "Enter Your Age",
                                                  ),
                                                  validator: (val) {
                                                    if (val!.isEmpty) {
                                                      return "Please Enter Age";
                                                    }
                                                  },
                                                  onSaved: (val) {
                                                    setState(() {
                                                      age = val!;
                                                      value = int.parse(age!);
                                                    });
                                                  },
                                                ),
                                                Row(
                                                  children: [
                                                    OutlinedButton(
                                                      onPressed: () {
                                                        nameController.clear();
                                                        cityController.clear();
                                                        ageController.clear();
                                                        setState(() {
                                                          name = "";
                                                          city = "";
                                                          age = "";
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("Cancel"),
                                                    ),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        if (globalKey
                                                            .currentState!
                                                            .validate()) {
                                                          (globalKey.currentState!
                                                              .save());
                                                          Map<String, dynamic>
                                                              newData = {
                                                            'name': name,
                                                            'age': value,
                                                            'city': city,
                                                          };
                                                          Student s =
                                                              Student.fromMap(
                                                                  newData);
                                                          int id = await DBHelper
                                                              .dbHelper
                                                              .update(
                                                                  s, data[i].id);

                                                          if (id == 1) {
                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    "Record Updated Successfully With id = ${data[i].id}"),
                                                                backgroundColor:
                                                                    Colors.green,
                                                              ),
                                                            );
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    "Record Updation failed..."),
                                                                backgroundColor:
                                                                    Colors
                                                                        .redAccent,
                                                              ),
                                                            );
                                                          }
                                                          setState(() {
                                                            fetchdata = DBHelper
                                                                .dbHelper
                                                                .fetchAllData();
                                                            name = "";
                                                            city = "";
                                                            age = "";
                                                          });
                                                          nameController.clear();
                                                          cityController.clear();
                                                          ageController.clear();
                                                          Navigator.of(context).pop();
                                                        }
                                                      },
                                                      child: const Text("Done"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  int id = await DBHelper.dbHelper
                                      .delete(data[i].id);

                                  if (id == 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Record Deleted Successfully With id = ${data[i].id}"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Record Deletion failed..."),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                  setState(() {
                                    fetchdata =
                                        DBHelper.dbHelper.fetchAllData();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        elevation: 3,
        focusColor: Colors.orange[300],
        autofocus: true,
        child: const Icon(Icons.add),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: AlertDialog(
                  title: const Text("Enter Your Information"),
                  content: Form(
                    key: globalKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter Your Name",
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please Enter Name";
                            }
                          },
                          onSaved: (val) {
                            setState(() {
                              name = val!;
                            });
                          },
                        ),
                        TextFormField(
                          controller: cityController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter Your City",
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please Enter City";
                            }
                          },
                          onSaved: (val) {
                            setState(() {
                              city = val!;
                            });
                          },
                        ),
                        TextFormField(
                          controller: ageController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter Your Age",
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please Enter Age";
                            }
                          },
                          onSaved: (val) {
                            setState(() {
                              age = val!;
                              value = int.parse(age!);
                            });
                          },
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                nameController.clear();
                                cityController.clear();
                                ageController.clear();
                                setState(() {
                                  name = "";
                                  city = "";
                                  age = "";
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (globalKey.currentState!.validate()) {
                                  (globalKey.currentState!.save());
                                  Map<String, dynamic> data = {
                                    'name': name,
                                    'city': city,
                                    'age': value,
                                    // 'image': img,
                                  };
                                  Student s = Student.fromMap(data);
                                  int id = await DBHelper.dbHelper.insert(s);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Record Insert Successfully With id = $id"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                    nameController.clear();
                                    cityController.clear();
                                    ageController.clear();
                                  setState(() {
                                    fetchdata = DBHelper.dbHelper.fetchAllData();
                                    name = "";
                                    city = "";
                                    age = "";
                                  });

                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text("Done"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// InkWell(
//   child: const CircleAvatar(
//     radius: 60,
//     child: Text("Add Image"),
//   ),
//   onTap: () async {
//     final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
//     File image = File(photo!.path);
//
//     img = await image.readAsBytes();
//   },
// ),