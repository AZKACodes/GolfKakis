const String emptyString = '';

String stringEmptyValue() => emptyString;

int intEmptyValue() => 0;

double floatEmptyValue() => 0;

double doubleEmptyValue() => 0;

bool booleanEmptyValue() => false;

int longEmptyValue() => 0;

List<T> emptyListValue<T>() => <T>[];

extension NullableStringDefaultValues on String? {
  String getValueOrEmpty() => this ?? emptyString;

  String getFormattedValueOrDefault() => this ?? emptyString;

  String toUppercase() => this?.toUpperCase() ?? emptyString;
}

extension NullableIntDefaultValues on int? {
  int getValueOrEmpty() => this ?? 0;
}

extension NullableBoolDefaultValues on bool? {
  bool getValueOrFalse() => this ?? false;
}

extension NullableLongDefaultValues on int? {
  int getValueOrZero() => this ?? 0;
}

extension NullableListDefaultValues<T> on List<T>? {
  List<T> getValueOrEmpty() => this ?? <T>[];
}
