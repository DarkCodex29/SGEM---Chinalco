import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/Repository/auth_repository.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/config/api/api_correo.dart';
import 'package:sgem/config/constants/config.dart';
import 'package:sgem/modules/pages/administracion/puestos_nivel/puestos_nivel_controller.dart';
import 'package:sgem/modules/pages/app/app.dart';

import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/controller/mail_controller.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.initializer.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

Future<void> main() async {
  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  final flag = ConfigFile.flag;

  if (kDebugMode) {
    debugPrint('flag: $flag');
  }

  if (flag case 'DEV' || 'STAGE') {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(record);
      if (record.error != null) {
        // ignore: avoid_print
        print('${record.error}');
        // ignore: avoid_print
        print('${record.stackTrace}');
      }
    });
  }
// Asegúrate de que esta es la primera línea en main()
  WidgetsFlutterBinding.ensureInitialized();
// Get Flutter Errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Logger.root.severe(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.root.severe(error, stack);
    return true;
  };

  // Configura servicios y el controlador
  ApiChinalco.dio = ApiChinalco.createDio(
    baseUrl: ConfigFile.apiUrl,
    apiKey: ConfigFile.apiKey,
  );

  // final id = Uri.base.queryParameters['id'];
  // final inPersonalOrigen = Uri.base.queryParameters['inPersonalOrigen'];
  //
  // if ((id ?? '') != '' && (inPersonalOrigen ?? '') != '') {
  //   Logger.root.info('id: $id, inPersonalOrigen: $inPersonalOrigen');
  //   return runApp(
  //     ViewApp(
  //       id: id!,
  //       inPersonalOrigen: inPersonalOrigen!,
  //     ),
  //   );
  // }
  //

  final authRepository = AuthRepository(
    rolPermisoApi: RolPermisoService(),
    api: UsuarioService(),
    computeSession: flag != 'DEV',
  )
    ..principalName.listen((user) {
      ApiChinalco.user = user;
    })
    ..initaliceServices = _initializeServices;
  // ..code = Uri.base.queryParameters['token'];
  // await authRepository.validateCode(Uri.base.pathSegments.firstOrNull);
  Get.put(authRepository);
  //
// Inicia la aplicación
  runApp(const App());
}

Future<void> _initializeServices() async {
  final dropdownController = Get.put(GenericDropdownController());
  dropdownController.isLoadingControl.value = true;

  try {
    final maestroDetalleService = MaestroDetalleService();
    final maestroService = MaestroService();
    final moduloMaestroService = ModuloMaestroService();

    Get.put(
      MaestraController(
        moduloMaestroService: moduloMaestroService,
        maestroService: maestroService,
        maestroDetalleService: maestroDetalleService,
        rolPermisoService: RolPermisoService(),
      ),
    );

    final personalService = PersonalService();

    Get.put(
      MailController(
        mailService: MailService(),
        personalService: personalService,
      ),
    );

    final dropdownInitializer = DropdownDataInitializer(
      dropdownController: dropdownController,
      maestroDetalleService: maestroDetalleService,
      moduloMaestroService: moduloMaestroService,
      personalService: personalService,
    );

    await dropdownInitializer.initializeAllDropdowns();

    Get.put(PuestosNivelController());
  } catch (e, stackTrace) {
    Logger('Main').severe('Error initializing service', e, stackTrace);
  } finally {
    dropdownController.completeLoading();
  }
}
