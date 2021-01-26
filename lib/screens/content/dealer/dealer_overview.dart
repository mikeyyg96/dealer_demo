import 'package:dealer_demo/screens/content/dealer/bloc/dealer_bloc.dart';
import 'package:dealer_demo/screens/exception/exception_screen.dart';
import 'package:dealer_demo/screens/loading/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class DealerOverviewScreen extends StatelessWidget {
  final EthereumAddress address;
  final Web3Client ethClient;
  final Credentials credentials;
  final dynamic abi;

  DealerOverviewScreen(
      {this.address, this.ethClient, this.credentials, this.abi});

  Future<List<String>> getConversion(BuildContext context, double usd) async {
    BlocProvider.of<DealerBloc>(context).add(ConvertUSDToETH(usd: usd));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> conversion = prefs.getStringList('conversion');
    print(conversion);
    return Future.value(conversion);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      initialData: ['', ''],
      future: getConversion(context, 10.0),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return SplashScreen();
          case ConnectionState.done:
            if (snapshot.hasData) {
              return Scaffold(
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildCover(context),
                    _buildContent(context, snapshot.requireData[0], snapshot.requireData[1]),
                  ],
                ),
              );
            }
            return ExceptionScreen();
          default:
            return ExceptionScreen();
        }
      },
    );
  }

  Widget _buildCover(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: AssetImage('assets/dealer_example.jpg'),
            fit: BoxFit.cover,
          ),
          IconButton(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 32.0, top: 64.0),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String usd, String eth) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Martin Smith',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '- Marijuana Dealer -',
              style: TextStyle(fontSize: 16.0, color: Colors.orange),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Deals mostly in the northern area of Pennsylvania but travels to and from New York to gather supplies. Strains include GMO Cookies, Ice Cream Cake, OG, Gorilla Glue and much more.',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Colors.black87,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(2.0, 2.0),
                  )
                ]),
            child: InkWell(
              onTap: () {
                final amount =
                    BigInt.from(double.parse(eth) * 1000000000000000000);
                BlocProvider.of<DealerBloc>(context).add(SendETH(
                    address: address,
                    ethClient: ethClient,
                    amount: amount,
                    credentials: credentials,
                    abi: abi));
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image(
                    image: AssetImage('assets/weed.png'),
                    fit: BoxFit.cover,
                    height: 75,
                    width: 50,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('( \$$usd\0 )'),
                        Text('$eth ETH'),
                        Text('per g')
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.local_play,
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Gift Code: 5134-3913',
                    style: TextStyle(color: Colors.purple, fontSize: 16.0),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  icon: FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  icon: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  icon: FaIcon(
                    FontAwesomeIcons.twitter,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
