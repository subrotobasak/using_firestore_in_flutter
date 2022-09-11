import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Text Fields' Controllers
  final TextEditingController _noteController = TextEditingController();

  final CollectionReference _todo =
      FirebaseFirestore.instance.collection('todo');

  // Add New Note
  Future<void> _createNote([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Add Data',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.primaries[
                          Random().nextInt(Colors.primaries.length)]),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  autofocus: true,
                  controller: _noteController,
                  decoration: InputDecoration(
                      labelText: 'Write Something',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    height: 45,
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)],
                    onPressed: () async {
                      final String note = _noteController.text;
                      await _todo.add({"note": note});
                      _noteController.text = '';

                      // "if (!mounted) return;"
                      //use for avoid Do not use BuildContexts across async gaps.
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        Text(
                          'Add Data',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  // Update Note

  Future<void> _updateNote([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      await showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Update Data',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)]),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    autofocus: true,
                    controller: _noteController,
                    decoration: InputDecoration(
                        labelText: 'Write Something',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      height: 45,
                      color: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)],
                      onPressed: () async {
                        final String note = _noteController.text;
                        await _todo
                            .doc(documentSnapshot.id)
                            .update({"note": note});
                        _noteController.text = '';
                        // "if (!mounted) return;"
                        //use for avoid Do not use BuildContexts across async gaps.
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          Text(
                            'Update Data',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          });
    }
  }

  // Delete Note
  Future<void> _deleteNote(String todoId) async {
    await _todo.doc(todoId).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have succesfully delete a note')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FireStore in Flutter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.00),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: _todo.snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasError) {
                      return const Text('Something Went Wromg');
                    }

                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text('Loading..');
                    }
                    {
                      return ListView.builder(
                          itemCount: streamSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                streamSnapshot.data!.docs[index];
                            return Card(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              child: Padding(
                                padding: const EdgeInsets.all(8.00),
                                child: ListTile(
                                  title: Text(documentSnapshot['note']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Note Update
                                      IconButton(
                                          onPressed: () {
                                            _updateNote(documentSnapshot);
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          )),

                                      // Note Delete
                                      IconButton(
                                          onPressed: () {
                                            _deleteNote(documentSnapshot.id);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),

      // Add New Note
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createNote();
        },
        backgroundColor:
            Colors.primaries[Random().nextInt(Colors.primaries.length)],
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
