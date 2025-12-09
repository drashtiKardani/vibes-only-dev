import 'package:flutter_bloc/flutter_bloc.dart';

class MotorSelectorCubit extends Cubit<ToyMotor> {
  MotorSelectorCubit() : super(ToyMotor.mainMotor);

  void selectMotor(ToyMotor toyMotor) => emit(toyMotor);

  void selectMotorNumber(int motorNumber) {
    assert(ToyMotor.values
        .map((e) => e.motorNumber)
        .contains(motorNumber)); // is either 0 or 2
    emit(ToyMotor.values.singleWhere((e) => e.motorNumber == motorNumber));
  }

  void switchMotor(ToyMotor toyMotor) {
    emit(toyMotor);
  }
}

enum ToyMotor {
  mainMotor(0),
  subMotor(1),
  thirdMotor(2);

  final int motorNumber;

  const ToyMotor(this.motorNumber);
}
