enum DataStatus { empty, offline, error, success, loading }

class EmptyType {
  const EmptyType();
}

class DataStatusModel<T> {
  const DataStatusModel({
    required this.data,
    required this.status,
    this.apiMessage = '',
    this.rawResponseCode = 0,
  });

  final T data;
  final DataStatus status;
  final String apiMessage;
  final int rawResponseCode;
}
