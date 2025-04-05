part of 'entrenamiento.modulo.dart';

extension EntrenamientoEnum on EntrenamientoModulo {
  bool get isCondicionExperiencia => condicion?.key == 9;
  bool get isCondicionEntrenamiento => condicion?.key == 10;
}
