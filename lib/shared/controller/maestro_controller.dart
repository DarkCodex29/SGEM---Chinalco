import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/shared/models/maestro.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/modules/modulo_model.dart';
import 'package:sgem/shared/modules/option.value.dart';

part 'maestro_detalle.dart';

class MaestraController extends GetxController {
  MaestraController({
    required ModuloMaestroService moduloMaestroService,
    required MaestroService maestroService,
    required MaestroDetalleService maestroDetalleService,
    required RolPermisoService rolPermisoService,
  })  : _maestroService = maestroService,
        _modulosMaestroService = moduloMaestroService,
        _maestroDetalleService = maestroDetalleService,
        _rolPermisoService = rolPermisoService;

  @override
  void onInit() {
    refreshMaestra();
    super.onInit();
  }

  final MaestroService _maestroService;
  final ModuloMaestroService _modulosMaestroService;
  final MaestroDetalleService _maestroDetalleService;
  final RolPermisoService _rolPermisoService;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  static final _logger = Logger('MaestraController');

  final maestros = <Maestro>[].obs;
  final roles = <OptionValue>[].obs;

  final modulosPermisos = <MaestroDetalle>[].obs;
  final assets = <MaestroDetalle>[].obs;
  final guardia = <MaestroDetalle>[].obs;
  final trainCondition = <MaestroDetalle>[].obs;
  final trainStatus = <MaestroDetalle>[].obs;
  final historialTabla = <MaestroDetalle>[].obs;
  final historialAccion = <MaestroDetalle>[].obs;
  final nivelResultados = <MaestroDetalle>[].obs;

  final trainModules = <Modulo>[].obs;

  final estados = <OptionValue>[
    const OptionValue(key: 1, nombre: 'Activo'),
    const OptionValue(key: 0, nombre: 'Inactivo'),
  ].obs;

  Future<void> refreshMaestra() => _load(
        () async => Future.wait([
          _getMaestros(),
          _getMaestroDetalle(
            _MaestrosDetalle.modulosPermisos,
            list: modulosPermisos,
          ),
          _getMaestroDetalle(
            _MaestrosDetalle.trainStatus,
            list: trainStatus,
          ),
          _getMaestroDetalle(
            _MaestrosDetalle.guardia,
            list: guardia,
          ),
          _getMaestroDetalle(
            _MaestrosDetalle.trainCondition,
            list: trainCondition,
          ),
          _getMaestroDetalle(
            _MaestrosDetalle.assets,
            list: assets,
          ),
          _getRoles(),
          _getTrainModules(),
          _getMaestroDetalle(
            _MaestrosDetalle.historialTabla,
            list: historialTabla,
          ),
          _getMaestroDetalle(
            _MaestrosDetalle.historialAccion,
            list: historialAccion,
          ),
          _getMaestroDetalle(
            _MaestrosDetalle.niveles,
            list: nivelResultados,
          ),
        ]),
      );

  Future<void> _getMaestros() async {
    final response = await _maestroService.getMaestros();
    if (response.success) {
      maestros.value = response.data!;
    } else {
      _logger.warning(response.message);
      maestros.value = [];
    }
  }

  Future<void> _getRoles() async {
    final response = await _rolPermisoService.getRoles();

    if (response.success) {
      roles.value = response.data!
          .where((e) => e.actived)
          .map(
            (e) => OptionValue(
              key: e.key,
              nombre: e.name,
            ),
          )
          .toList();
    } else {
      roles.value = [];
    }
  }

  Future<void> _getMaestroDetalle(
    _MaestrosDetalle detail, {
    required RxList<MaestroDetalle> list,
  }) async {
    final response =
        await _maestroDetalleService.listarMaestroDetallePorMaestro(
      detail.value,
    );

    if (response.success) {
      list.value = response.data!;
    } else {
      _logger.warning(
        'Error al cargar maestro detalle ${detail.value}',
        response.message,
      );
      list.value = [];
    }
  }

  Future<void> _getTrainModules() async {
    final response = await _modulosMaestroService.getModules();

    if (response.success) {
      trainModules.value = response.data!.toList();
    } else {
      trainModules.value = [];
    }
  }

  Future<void> _load(Future<void> Function() function) async {
    _isLoading.value = true;
    Logger('MaestraController').info('Loading...');
    try {
      await function();
    } catch (e, stackTrace) {
      Logger('MaestraController')
          .severe('Error al cargar maestra', e, stackTrace);
    } finally {
      _isLoading.value = false;
      Logger('MaestraController').info('Loaded');
    }
  }
}
