const String emptyString = '';
const bool emptyBool = false;
const int emptyInt = 0;
const double emptyDouble = 0;

String stringEmptyValue() => emptyString;

int intEmptyValue() => emptyInt;

double floatEmptyValue() => emptyDouble;

double doubleEmptyValue() => emptyDouble;

bool booleanEmptyValue() => emptyBool;

int longEmptyValue() => emptyInt;

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
