import 'package:get_it/get_it.dart';
import 'package:notes_app_rxvms/data/services/db_helper/db_helper.dart';
import 'package:notes_app_rxvms/managers/app_manager.dart';

GetIt sl = GetIt.instance;

void setUpServiceLocator() {
  //Register Database Service
  sl.registerLazySingleton<DatabaseHelper>(
      () => DatabaseHelperImplementation());

  // Managers
  sl.registerSingleton<AppManager>(new AppManagerImplementation());
}
