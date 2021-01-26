part of 'dealer_bloc.dart';

@immutable
abstract class DealerState {
  const DealerState();

  @override
  List<Object> get props => [];
}

class DealerInitial extends DealerState {}
