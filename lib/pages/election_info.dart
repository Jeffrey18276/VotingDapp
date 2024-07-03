import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../services/functions.dart' as functions;
import '../services/functions.dart'; // Import functions.dart file


class ElectionInfo extends StatefulWidget {
  final Web3Client ethClient;
  final String electionName;
  const ElectionInfo({Key? key, required this.ethClient, required this.electionName})
      : super(key: key);


  @override
  _ElectionInfoState createState() => _ElectionInfoState();
}


class _ElectionInfoState extends State<ElectionInfo> {
  late Future<List> _candidatesFuture;
  late Future<List> _totalVotesFuture;


  // Use http.Client for Web3Client creation
  late http.Client httpClient;


  TextEditingController addCandidateController = TextEditingController();
  TextEditingController authorizeVoterController = TextEditingController();


  @override
  void initState() {
    super.initState();
    httpClient = http.Client(); // Initialize the HTTP client
    _fetchData();
  }


  void _fetchData() {
    _candidatesFuture = functions.runParallelProcessing(widget.ethClient)
        .then((_) => getCandidatesNum(widget.ethClient)); // Fetch candidates after parallel processing
    _totalVotesFuture = getTotalVotes(widget.ethClient); // Fetch total votes separately
  }




  Future<List> _fetchCandidates(Web3Client ethClient) async {
    return await compute(fetchCandidatesInIsolate, ethClient);
  }


  Future<List> _fetchTotalVotes(Web3Client ethClient) async {
    return await compute(fetchTotalVotesInIsolate, ethClient);
  }


  static Future<List> fetchCandidatesInIsolate(Web3Client ethClient) async {
    return await functions.getCandidatesNum(ethClient);
  }


  static Future<List> fetchTotalVotesInIsolate(Web3Client ethClient) async {
    return await functions.getTotalVotes(ethClient);
  }




  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.electionName),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            onPressed: () {
              setState(() {
                _fetchData();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              // Display candidates and total votes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      FutureBuilder<List>(
                        future: _candidatesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Text(
                            snapshot.data![0].toString(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text('Total Candidates')
                    ],
                  ),
                  Column(
                    children: [
                      FutureBuilder<List>(
                        future: _totalVotesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Text(
                            snapshot.data![0].toString(),
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text('Total Votes')
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Text fields for adding candidate and authorizing voter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addCandidateController,
                      decoration: InputDecoration(hintText: 'Enter Candidate Name'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await addCandidate(addCandidateController.text, widget.ethClient);
                      setState(() {
                        _fetchData(); // Refresh data after adding a candidate
                      });
                    },
                    child: Text('Add Candidate'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: authorizeVoterController,
                      decoration: InputDecoration(hintText: 'Enter Voter address'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      authorizeVoter(authorizeVoterController.text, widget.ethClient);
                      setState(() {
                        _fetchData(); // Refresh data after authorizing a voter
                      });
                    },
                    child: Text('Authorize Voter'),
                  ),
                ],
              ),
              Divider(),
              // List of candidates with vote button
              FutureBuilder<List>(
                future: _candidatesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Column(
                      children: [
                        for (int i = 0; i < snapshot.data![0].toInt(); i++)
                          FutureBuilder<List>(
                            future: candidateInfo(i, widget.ethClient),
                            builder: (context, candidatesnapshot) {
                              if (candidatesnapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return ListTile(
                                  title: Text('Name: ' + candidatesnapshot.data![0][0].toString()),
                                  subtitle: Text('Votes: ' + candidatesnapshot.data![0][1].toString()),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      vote(i, widget.ethClient);
                                      setState(() {
                                        _fetchData(); // Refresh data after voting
                                      });
                                    },
                                    child: Text('Vote'),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }




  @override
  void dispose() {
    httpClient.close(); // Close the HTTP client when disposing the widget
    super.dispose();
  }
}


