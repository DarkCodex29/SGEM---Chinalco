class StringValue {
  const StringValue({
    required this.key,
    required this.value,
  });

  factory StringValue.fromJson(Map<String, dynamic> json) => StringValue(
        key: json['Key'] as String,
        value: json['Nombre'] as String,
      );

  final String key;
  final String value;

  Map<String, dynamic> toJson() => {
        'Key': key,
        'Nombre': value,
      };

  @override
  String toString() => 'StringValue(key: $key, value: $value)';
}
