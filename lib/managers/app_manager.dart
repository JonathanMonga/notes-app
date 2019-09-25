import 'dart:async';

import 'package:notes_app_rxvms/data/models/note.dart';
import 'package:notes_app_rxvms/data/services/db_helper/db_helper.dart';
import 'package:notes_app_rxvms/service_locator.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

abstract class AppManager {
  RxCommand<Note, int> insertNoteCommand;
  RxCommand<Note, int> updateNoteCommand;
  RxCommand<Note, int> deleteNoteCommand;
  RxCommand<void, int> getCountCommand;
  RxCommand<void, List<Note>> getNoteListCommand;
  RxCommand<String, String> updateSearchStringCommand;

  Observable<CommandResult<List<Note>>> get searchNotes;

  Future init();
}

class AppManagerImplementation implements AppManager {
  @override
  RxCommand<Note, int> deleteNoteCommand;

  @override
  RxCommand<void, int> getCountCommand;

  @override
  RxCommand<void, List<Note>> getNoteListCommand;

  @override
  RxCommand<String, String> updateSearchStringCommand;

  @override
  RxCommand<Note, int> insertNoteCommand;

  @override
  RxCommand<Note, int> updateNoteCommand;

  @override
  Observable<CommandResult<List<Note>>> get searchNotes {
    return Observable.combineLatest2<CommandResult<List<Note>>, String,
            CommandResult<List<Note>>>(
        getNoteListCommand.results,
        updateSearchStringCommand.startWith(""),
        (result, s) => new CommandResult<List<Note>>(
            result.data != null
                ? result.data.where((song) => song.title.contains(s))?.toList()
                : null,
            result.error,
            result.isExecuting));
  }

  AppManagerImplementation() {
    getNoteListCommand = RxCommand.createAsyncNoParam<List<Note>>(
        () async => sl.get<DatabaseHelper>().getNoteList(),
        emitLastResult: true);

    updateNoteCommand = RxCommand.createAsync<Note, int>(
        (note) async => sl.get<DatabaseHelper>().updateNote(note));

    insertNoteCommand = RxCommand.createAsync<Note, int>(
        (note) async => sl.get<DatabaseHelper>().updateNote(note));

    deleteNoteCommand = RxCommand.createAsync<Note, int>(
        (note) async => sl.get<DatabaseHelper>().updateNote(note));

    getCountCommand = RxCommand.createAsyncNoParam<int>(
        () async => sl.get<DatabaseHelper>().getCount());

    updateSearchStringCommand = RxCommand.createSync((s) => s);

    updateNoteCommand.listen((onData) {
      getNoteListCommand.execute();
    });

    insertNoteCommand.listen((onData) {
      getNoteListCommand.execute();
    });

    deleteNoteCommand.listen((onData) {
      getNoteListCommand.execute();
    });
  }

  Future init() async {
    sl.get<DatabaseHelper>().initializeDatabase();
    
    getNoteListCommand();

    getNoteListCommand
        .listen((onData) => onData.forEach((data) => print(data.title)));
  }
}
