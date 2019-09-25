import 'dart:async';

import 'package:notes_app_rxvms/data/models/note.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';

abstract class AppManager {
  RxCommand<void, List<Map<String, dynamic>>> getNoteMapListCommand;
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
  RxCommand<void, List<Map<String, >>> getNoteMapListCommand;

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
    
    loadSongsCommand = RxCommand.createAsyncNoParam<List<Song>>(
        () async => sl.get<LushitrapService>().loadSongs(),
        emitLastResult: true);

    loadSongsCommand.execute();

    updateSearchStringCommand = RxCommand.createSync((s) => s);
  }

  Future init() async {
    updateSearchStringCommand.results.listen(print);

    loadSongsCommand.results.listen((data) => print(
        "Has data: ${data.hasData}  has error:   ${data.hasError}, ${data.isExecuting}"));
  }

  @override
  RxCommand<String, String> updateSearchStringCommand;
}
