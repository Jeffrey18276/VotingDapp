import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:voting_dapp1/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

import '../services/functions.dart';
import 'election_info.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Client httpClient;
  late Web3Client ethClient;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initWeb3Client();
  }

  @override
  void dispose() {
    httpClient.close();
    super.dispose();
  }

  Future<void> initWeb3Client() async {
    httpClient = Client();
    ethClient = Web3Client(sepoliaurl, httpClient);
  }

  Future<void> startElectionAndNavigate(String electionName) async {
    if (electionName.isNotEmpty) {
      try {
        await startElection(electionName, ethClient);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElectionInfo(
              ethClient: ethClient,
              electionName: electionName,
            ),
          ),
        );
      } catch (e) {
        print('Failed to start election: $e');
        // Handle the error gracefully, e.g., show an error message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Election'),
        backgroundColor: Colors.deepPurple,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight:const  Radius.circular(20),
            bottomLeft:const  Radius.circular(20),
            bottomRight: const Radius.circular(20)
          )
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Enter election name',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => startElectionAndNavigate(controller.text),
                child: Text('Start Election'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
