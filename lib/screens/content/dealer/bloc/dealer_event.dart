part of 'dealer_bloc.dart';

@immutable
abstract class DealerEvent {
  const DealerEvent();

  @override
  List<Object> get props => [];
}

class ConvertUSDToETH extends DealerEvent {
  final double usd;
  ConvertUSDToETH({this.usd});
}

class SendETH extends DealerEvent {
  final EthereumAddress address;
  final Web3Client ethClient;
  final BigInt amount;
  final Credentials credentials;
  final dynamic abi;
  SendETH({this.address, this.ethClient, this.amount, this.credentials, this.abi});
}


