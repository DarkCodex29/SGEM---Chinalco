import 'dart:developer';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/config/api/api.modulo.maestro.dart';
import 'package:sgem/config/api/api.personal.dart';
import 'package:sgem/shared/modules/modulo.maestro.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class DropdownDataInitializer {
  const DropdownDataInitializer({
    this.dropdownController,
    this.maestroDetalleService,
    this.moduloMaestroService,
    this.personalService,
  });

  final GenericDropdownController? dropdownController;
  final MaestroDetalleService? maestroDetalleService;
  final ModuloMaestroService? moduloMaestroService;
  final PersonalService? personalService;

  Logger get _logger => Logger('DropdownDataInitializer');

  /// Método que inicializa la carga de todos los dropdowns
  Future<void> initializeAllDropdowns() async {
    await Future.wait([
      _loadEstado(),
      _loadYears(),
      _loadGuardiaFiltro(),
      _loadGuardiaRegistro(),
      _loadEquipo(),
      _loadModulo(),
      _loadCategoriaLicencia(),
      _loadCategoria(),
      _loadEmpresaCapacitacion(),
      _loadCapacitacion(),
      _loadEntrenador(),
      _loadEstadoEntrenamiento(),
      _loadCondicion(),
      _loadEstadoModulo(),
    ]);
  }

  Future<List<OptionValue>> _handleResponse(
    Future<ResponseHandler<dynamic>> response,
  ) async {
    final res = await response;
    if (res.success && res.data != null) {
      if (res.data is List<ModuloMaestro>) {
        return res.data!.map<OptionValue>((item) {
          return OptionValue(
            key: item.key,
            nombre: item.modulo,
          );
        }).toList();
      }
      if (res.data is List<Personal>) {
        return res.data!.map<OptionValue>((item) {
          return OptionValue(
            key: item.key,
            nombre: item.nombreCompleto,
          );
        }).toList();
      }
      return res.data!.map<OptionValue>((item) {
        return OptionValue(
          key: item.key,
          nombre: item.valor ??
              item.nombreCompleto ??
              item.modulo ??
              "No encontrado",
        );
      }).toList();
    }
    return <OptionValue>[];
  }

  Future<void> _loadEstado() async {
    dropdownController!.initializeDropdown('estado');
    dropdownController!.optionsMap['estado']?.addAll([
      OptionValue(key: 0, nombre: 'Todos'),
      OptionValue(key: 95, nombre: 'Activo'),
      OptionValue(key: 96, nombre: 'Cesado'),
    ]);
    _logger.info('Estado cargado');
  }

  Future<void> _loadYears() async {
    final int startYear = 2024; // Año inicial fijo
    final int currentYear = DateTime.now().year;
    final List<OptionValue> yearOptions = [
      OptionValue(key: 0, nombre: 'Todos'),
      // for (int year = startYear; year <= currentYear; year++)
      //   OptionValue(key: year - startYear + 1, nombre: '$year')
    ];

    dropdownController!.initializeDropdown('años');

    // dropdownController!.optionsMap['años']?.addAll([
    //   OptionValue(key: 0, nombre: 'Todos'),
    //   OptionValue(key: 1, nombre: '2024'),
    //   OptionValue(key: 2, nombre: '2023'),
    //   OptionValue(key: 3, nombre: '2022'),
    //   OptionValue(key: 4, nombre: '2021'),
    //   OptionValue(key: 5, nombre: '2020'),
    //   OptionValue(key: 6, nombre: '2019'),
    //   OptionValue(key: 7, nombre: '2018'),
    //   OptionValue(key: 8, nombre: '2017'),
    //   OptionValue(key: 9, nombre: '2016'),
    //   OptionValue(key: 10, nombre: '2015'),
    // ]);

    dropdownController!.optionsMap['años']?.addAll(yearOptions);
    _logger.info('Estado cargado');
  }

  /// Métodos de carga específicos para cada dropdown, utilizando el servicio correcto

  Future<void> _loadGuardiaFiltro() async {
    await dropdownController!.loadOptions('guardiaFiltro', () async {
      final options = await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(2),
      );
      options.insert(0, OptionValue(key: 0, nombre: 'Todos'));
      return options;
    });
    _logger.info('Guardia cargada');
  }

  Future<void> _loadGuardiaRegistro() async {
    await dropdownController!.loadOptions('guardiaRegistro', () async {
      final options = await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(2),
      );
      return options;
    });
    _logger.info('Guardia cargada');
  }

  Future<void> _loadCategoriaLicencia() async {
    await dropdownController!.loadOptions('categoriaLicencia', () async {
      final options = await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(12),
      );
      return options;
    });
    _logger.info('Categoria Licencia cargado');
  }

  Future<void> _loadEquipo() async {
    await dropdownController!.loadOptions('equipo', () async {
      return await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(5),
      );
    });
    _logger.info('Equipo cargado');
  }

  Future<void> _loadModulo() async {
    await dropdownController!.loadOptions('modulo', () async {
      return await _handleResponse(
        moduloMaestroService!.listarMaestros(),
      );
    });
    _logger.info('Modulo cargado');
  }

  Future<void> _loadCategoria() async {
    await dropdownController!.loadOptions('categoria', () async {
      final options = await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(9),
      );

      options.insert(0, OptionValue(key: 0, nombre: 'Todos'));
      return options;
    });
    _logger.info('Categoria cargada');
  }

  Future<void> _loadEmpresaCapacitacion() async {
    try {
      final response =
          await maestroDetalleService!.listarMaestroDetallePorMaestro(8);

      if (!response.success || response.data == null) {
        _logger.info(
          'Error al cargar empresas de capacitación: ${response.message}',
        );
        return;
      }

      final options = response.data;

      final empresasInternas = options?.where((empresa) {
        return empresa.detalleRelacion?.nombre == 'Interna';
      }).toList();

      final empresasExternas = options?.where((empresa) {
        return empresa.detalleRelacion?.nombre == 'Externa' ||
            empresa.detalleRelacion?.nombre == null;
      }).toList();

      await dropdownController!.loadOptions(
        'empresaCapacitadoraInterna',
        () async => empresasInternas
            ?.map((e) => OptionValue(key: e.key, nombre: e.valor))
            .toList(),
      );
      await dropdownController!.loadOptions(
        'empresaCapacitadoraExterna',
        () async => empresasExternas
            ?.map((e) => OptionValue(key: e.key, nombre: e.valor))
            .toList(),
      );

      _logger
        ..info(
          'Opciones cargadas para empresaCapacitadoraInterna: '
          '${dropdownController!.getOptionsFromKey('empresaCapacitadoraInterna').map((e) => e.nombre)}',
        )
        ..info(
          'Opciones cargadas para empresaCapacitadoraExterna: '
          '${dropdownController!.getOptionsFromKey('empresaCapacitadoraExterna').map((e) => e.nombre)}',
        );
    } catch (e) {
      _logger.info('Error al cargar empresas de capacitación: $e');
    }
  }

  Future<void> _loadCapacitacion() async {
    await dropdownController!.loadOptions('capacitacion', () async {
      return await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(7),
      );
    });
    _logger.info('Capacitación cargada');
  }

  Future<void> _loadEntrenador() async {
    await dropdownController!.loadOptions('entrenador', () async {
      return await _handleResponse(
        personalService!.listarEntrenadores(),
      );
    });
    _logger.info('Entrenador cargado');
  }

  Future<void> _loadEstadoEntrenamiento() async {
    await dropdownController!.loadOptions('estadoEntrenamiento', () async {
      return await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(4),
      );
    });
    _logger.info('Estado de entrenamiento cargado');
  }

  Future<void> _loadCondicion() async {
    await dropdownController!.loadOptions('condicion', () async {
      return await _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(3),
      );
    });
    _logger.info('Condición cargada');
  }

  Future<void> _loadEstadoModulo() async {
    await dropdownController!.loadOptions('estadoModulo', () async {
      return _handleResponse(
        maestroDetalleService!.listarMaestroDetallePorMaestro(10),
      );
    });
    _logger.info('Estados de módulo cargados');
  }
}
