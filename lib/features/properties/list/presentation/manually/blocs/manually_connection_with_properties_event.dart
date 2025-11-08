abstract class ManuallyConnectionWithPropertiesEvent {}

class FetchManuallyConnectionWithPropertiesEvent
    extends ManuallyConnectionWithPropertiesEvent {
  final String cadastralKey;

  FetchManuallyConnectionWithPropertiesEvent(this.cadastralKey);
}
