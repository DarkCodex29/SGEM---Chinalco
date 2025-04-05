import 'package:json_annotation/json_annotation.dart';
import 'package:sgem/shared/modules/string_value.dart';

part 'mail.g.dart';

@JsonSerializable(
  createFactory: false,
  fieldRename: FieldRename.pascal,
  includeIfNull: false,
)
class Mail {
  const Mail({
    required this.destinatarios,
    required this.acronimo,
    this.variables,
    this.copiaDestinatarios,
    this.adjuntos,
  });

  final List<String> destinatarios;
  final String acronimo;

  final List<String>? copiaDestinatarios;

  @JsonKey(toJson: _variablesToJson)
  final Map<String, String>? variables;

  final List<StringValue>? adjuntos;

  Map<String, dynamic> toJson() => _$MailToJson(this);

  @override
  String toString() {
    return 'Mail{destinatarios: $destinatarios, acronimo: $acronimo, variables: $variables, copiaDestinatarios: $copiaDestinatarios, adjuntos: $adjuntos}';
  }
}

List<StringValue> _variablesToJson(Map<String, String>? json) {
  final List<StringValue> variables = [];
  if (json == null) return variables;
  json.forEach((key, value) {
    variables.add(StringValue(key: key, value: value));
  });
  return variables;
}
