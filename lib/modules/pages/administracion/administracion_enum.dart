enum AdministracionScreen {
  none._('Administración'),
  maestro._('Mantenimiento de maestros'),
  modulos._('Mantenimiento de módulos'),
  rolesPermisos._('Roles y permisos'),
  usuarios._('Lista de usuarios'),
  fechas._('Lista de fechas disponibles por guardia'),
  fechasCronograma._('Carga de cronograma de fechas disponibles por guardia'),
  consultaHistorial._('Consulta de historial de modificaciones del sistema'),
  puestos._('Mantenimiento de puestos por nivel');
  // equipos._('Mantenimiento de equipos');

  const AdministracionScreen._(this.pageName);

  final String pageName;
}
