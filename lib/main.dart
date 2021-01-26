import 'dart:convert';

import 'package:dealer_demo/screens/content/dealer/bloc/dealer_bloc.dart';
import 'package:dealer_demo/screens/content/dealer/dealer_overview.dart';
import 'package:dealer_demo/screens/exception/exception_screen.dart';
import 'package:dealer_demo/screens/loading/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  List<dynamic> package = new List<dynamic>();
  

  Future<List<dynamic>> getEthereumClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _abicode = await getAbi();
    final _rpcUrl = "http://192.168.0.23:7545";
    final _wsUrl = "ws://192.168.0.23:7545/";
    final _privateKey = "9891aedc7a5e634b77554e4dbeac7ed0dc8845fe08d3cbd578e94b6ff6703775";
    
    final _contractAddress = EthereumAddress.fromHex(_abicode["networks"]["5777"]["address"]);
    
    final _receiver = EthereumAddress.fromHex('0x83C94af5d7af787f571AD86B259b462CB292869D');

    final _ethClient = new Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    final _credentials = await _ethClient.credentialsFromPrivateKey(_privateKey);

    final _myAddress = await _credentials.extractAddress();
    await prefs.setString('myAddress', '$_myAddress');

    print(_contractAddress);
    print(_myAddress);

    package.add(_receiver);
    package.add(_ethClient);
    package.add(_credentials);
    package.add(_abicode);

    return package;
  }

  Future<dynamic> getAbi() async {
    String abiStringFile = await rootBundle.loadString("src/abis/Migrations.json");
    final jsonAbi = jsonDecode(abiStringFile);
    return jsonAbi;
  }

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dealer Demo',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData(
        fontFamily: 'Montserrat',
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DealerBloc>(
            create: (context) => DealerBloc(),
          ),
        ],
        child: FutureBuilder<List<dynamic>>(
          future: getEthereumClient(),
          builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return SplashScreen();
              case ConnectionState.done:
                return DealerOverviewScreen(address: snapshot.requireData[0], ethClient: snapshot.requireData[1], credentials: snapshot.requireData[2], abi: snapshot.requireData[3]);
              default:
                return ExceptionScreen();
            }
          },
        ),
      ),
    );
  }
}
