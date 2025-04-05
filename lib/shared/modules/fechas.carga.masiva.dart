class FechaCargaMasiva {
  int anio;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  String guardia;
  bool valido;
  final int index;

  bool esErrorFechaInicio;
  String? errorFechaInicio;
  bool esErrorFechaFin;
  String? errorFechaFin;
  bool esErrorGuardia;

  FechaCargaMasiva({
    required this.anio,
    required this.fechaInicio,
    required this.fechaFin,
    required this.guardia,
    required this.valido,
    required this.index,
    this.errorFechaInicio,
    this.errorFechaFin,
    required this.esErrorFechaFin,
    required this.esErrorFechaInicio,
    required this.esErrorGuardia,
  });

  FechaCargaMasiva copyWith({
    int? anio,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? guardia,
    bool? valido,
    int? index,
  }) =>
      FechaCargaMasiva(
        anio: anio ?? this.anio,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        guardia: guardia ?? this.guardia,
        valido: valido ?? this.valido,
        index: index ?? this.index,
        errorFechaInicio: errorFechaInicio ?? this.errorFechaInicio,
        errorFechaFin: errorFechaFin ?? this.errorFechaFin,
        esErrorFechaFin: esErrorFechaFin ?? this.esErrorFechaFin,
        esErrorFechaInicio: esErrorFechaInicio ?? this.esErrorFechaInicio,
        esErrorGuardia: esErrorGuardia ?? this.esErrorGuardia,
      );
}
