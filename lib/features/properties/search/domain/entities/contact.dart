import 'package:equatable/equatable.dart';

class PhoneEntity extends Equatable {
  final int telefonoid;
  final String numero;
  const PhoneEntity(this.telefonoid, this.numero);
  @override
  List<Object?> get props => [telefonoid, numero];
}

class EmailEntity extends Equatable {
  final int correoid;
  final String email;
  const EmailEntity(this.correoid, this.email);
  @override
  List<Object?> get props => [correoid, email];
}
