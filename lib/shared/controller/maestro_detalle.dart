part of 'maestro_controller.dart';

enum _MaestrosDetalle {
  modulosPermisos._(11),
  trainStatus._(4),
  assets._(5),
  guardia._(2),
  trainCondition._(3),
  historialTabla._(13),
  historialAccion._(14),
  niveles._(15);

  const _MaestrosDetalle._(this.value);
  final int value;
}

extension MaestroDetalleOptionValue on RxList<MaestroDetalle> {
  RxList<OptionValue> toOptionValue() {
    return map(
      (e) => OptionValue(
        key: e.key,
        nombre: e.valor,
      ),
    ).toList().obs;
  }

  RxList<Detalle> toDetalle() {
    return map(
      (e) => Detalle(
        key: e.key!,
        nombre: e.valor!,
        maestro: OptionValue(
          key: e.maestro.key,
          nombre: e.maestro.nombre,
        ),
        detalleRelacion: e.detalleRelacion != null
            ? OptionValue(
                key: e.detalleRelacion!.key,
                nombre: e.detalleRelacion!.nombre,
              )
            : null,
        activo: switch (e.activo) {
          'S' => true,
          'N' => false,
          _ => throw Exception('Estado no válido'),
        },
      ),
    ).toList().obs;
  }
}

extension ModuloOptionValue on RxList<Modulo> {
  RxList<OptionValue> toOptionValue() {
    return map(
      (e) => OptionValue(
        key: e.key,
        nombre: e.module,
      ),
    ).toList().obs;
  }
}
