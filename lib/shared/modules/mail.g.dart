// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$MailToJson(Mail instance) {
  final val = <String, dynamic>{
    'Destinatarios': instance.destinatarios,
    'Acronimo': instance.acronimo,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('CopiaDestinatarios', instance.copiaDestinatarios);
  val['Variables'] = _variablesToJson(instance.variables);
  writeNotNull('Adjuntos', instance.adjuntos);
  return val;
}
