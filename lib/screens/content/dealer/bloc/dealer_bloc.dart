import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

part 'dealer_event.dart';
part 'dealer_state.dart';

class DealerBloc extends Bloc<DealerEvent, DealerState> {
  DealerBloc() : super(DealerInitial());

  @override
  Stream<DealerState> mapEventToState(
    DealerEvent event,
  ) async* {
    if (event is ConvertUSDToETH) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await _getETHValue();
      double conversion = event.usd / response.data['ethereum']['usd'];
      await prefs.setStringList('conversion' , ['${event.usd.toString()}', '${conversion.toStringAsFixed(10)}']);
    } else if (event is SendETH) {
      final response = await submit(
        'transferMoney',
        [event.address, event.amount],
        event.ethClient,
        event.credentials,
        event.abi
      );
      print('The transaction hash: $response');
    }
  }
}

Future<DeployedContract> loadContract(dynamic abi) async {
  final _contractAddress = EthereumAddress.fromHex(abi["networks"]["5777"]["address"]);

  final _abiCode = jsonEncode(abi["abi"]);
  final contract = DeployedContract(ContractAbi.fromJson(_abiCode, "Migrations"), _contractAddress);
  print(contract.address);
  return contract;
}


Future<String> submit(String functionName, List<dynamic> args, Web3Client ethClient, Credentials credentials, dynamic abi) async {
  final contract = await loadContract(abi);
  final address = await credentials.extractAddress();
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction(
      from: address,
      to: args[0],
      maxGas: 100000,
      gasPrice: EtherAmount.inWei(BigInt.one),
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1)
    ),
    chainId: 3
  );
  return result.toString();
}


Future<Response> _getETHValue() async {
  Dio dio = new Dio();
  final _headers = {
    HttpHeaders.contentTypeHeader: "application/json"
  };
  return await dio.get('https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd&include_last_updated_at=true', options: Options(headers: _headers));
}


