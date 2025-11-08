abstract class ConnectionWithPropertiesEvent {}

class FetchConnectionWithPropertiesEvent extends ConnectionWithPropertiesEvent {
  final String cadastralKey;

  FetchConnectionWithPropertiesEvent(this.cadastralKey);
}
