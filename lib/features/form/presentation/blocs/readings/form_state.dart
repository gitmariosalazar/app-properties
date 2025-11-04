// features/form/presentation/blocs/readings/form_state.dart
part of 'form_bloc.dart';

abstract class FormState {}

class FormInitial extends FormState {}

class FormLoading extends FormState {}

class FormSuccess extends FormState {
  final Map<String, dynamic> data;

  FormSuccess(this.data);
}

class FormFailure extends FormState {
  final String message;

  FormFailure({required this.message});
}
