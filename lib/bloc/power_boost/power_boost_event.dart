part of 'power_boost_bloc.dart';

abstract class PowerBoostEvent {}

class LoadPowerBoostDataEvent extends PowerBoostEvent {}

class StartBoostEvent extends PowerBoostEvent {}