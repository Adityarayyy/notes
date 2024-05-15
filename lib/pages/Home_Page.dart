import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heepme/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firstore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open txt fld
  void openNoteBox({String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      // add note
                      if (docId == null) {
                        firestoreService.addNote(textController.text);
                      }

                      // update

                      else {
                        firestoreService.updateNode(docId, textController.text);
                      }

                      // clr
                      textController.clear();
                      // close
                      Navigator.pop(context);
                    },
                    child: Text('add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: openNoteBox,
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed:
          openNoteBox,
      
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if data get all docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display list
            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // get each indiv doc
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // get note from each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // display tile
                  return ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => openNoteBox(docId: docID),
                          icon: const Icon(Icons.edit),
                        ),
                        // delete
                        IconButton(
                          onPressed: () => firestoreService.deleteNode(docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return const Text('no notes available');
          }
        },
      ),
    );
  }
}
