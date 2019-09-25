import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app_rxvms/data/models/note.dart';
import 'package:notes_app_rxvms/managers/app_manager.dart';
import 'package:notes_app_rxvms/service_locator.dart';
import 'package:notes_app_rxvms/utils/widgets.dart';
import 'package:notes_app_rxvms/widgets/note_detail.dart';
import 'package:notes_app_rxvms/widgets/search_note.dart';
import 'package:rx_command/rx_command.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  int axisCount = 2;

  @override
  Widget build(BuildContext context) {
    var appManager = sl.get<AppManager>();
    var notes = appManager.getNoteListCommand.results;
    var lastNoteList = appManager.getNoteListCommand.lastResult;

    Widget myAppBar(List<Note> notes) {
      return AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.headline),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: notes.length == 0
            ? Container()
            : IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () async {
                  final Note result = await showSearch(
                      context: context, delegate: NotesSearch(notes: notes));
                  if (result != null) {
                    navigateToDetail(result, 'Edit Note');
                  }
                },
              ),
        actions: <Widget>[
          notes.length == 0
              ? Container()
              : IconButton(
                  icon: Icon(
                    axisCount == 2 ? Icons.list : Icons.grid_on,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      axisCount = axisCount == 2 ? 4 : 2;
                    });
                  },
                )
        ],
      );
    }

    return StreamBuilder(
        stream: notes,
        initialData: new CommandResult(lastNoteList, null, false),
        builder: (BuildContext context,
            AsyncSnapshot<CommandResult<List<Note>>> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: myAppBar(snapshot.data.data),
              body: snapshot.data.data.length == 0
                  ? Container(
                      color: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              'Click on the add button to add a new note!',
                              style: Theme.of(context).textTheme.body1),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.white,
                      child: getNotesList(snapshot.data.data),
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  navigateToDetail(Note('', '', 3, 0), 'Add Note');
                },
                tooltip: 'Add Note',
                shape: CircleBorder(
                    side: BorderSide(color: Colors.black, width: 2.0)),
                child: Icon(Icons.add, color: Colors.black),
                backgroundColor: Colors.white,
              ),
            );
          } else {
            return Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Click on the add button to add a new note!',
                      style: Theme.of(context).textTheme.body1),
                ),
              ),
            );
          }
        });
  }

  Widget getNotesList(List<Note> notes) {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(notes[index], 'Edit Note');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: colors[notes[index].color],
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          notes[index].title,
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                    ),
                    Text(
                      getPriorityText(notes[index].priority),
                      style: TextStyle(
                          color: getPriorityColor(notes[index].priority)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            notes[index].description == null
                                ? ''
                                : notes[index].description,
                            style: Theme.of(context).textTheme.body2),
                      )
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(notes[index].date,
                          style: Theme.of(context).textTheme.subtitle),
                    ])
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
        break;
      case 2:
        return '!!';
        break;
      case 3:
        return '!';
        break;

      default:
        return '!';
    }
  }

  // void _delete(BuildContext context, Note note) async {
  //   int result = await sl.get<AppManager>().deleteNoteCommand(note.id);
  //   if (result != 0) {
  //     _showSnackBar(context, 'Note Deleted Successfully');
  //   }
  // }

  // void _showSnackBar(BuildContext context, String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  void navigateToDetail(Note note, String title) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));
  }
}
