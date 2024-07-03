import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:voting_dapp1/utils/constants.dart';

class HighPerformance {
  static Future<String> startElection(String name, Web3Client ethClient) async {
    try {
      // Load contract and prepare credentials concurrently using compute
      final List<dynamic> results = await Future.wait([
        compute(_loadContract, null),
        compute(_getCredentials, owner_privatKey),
      ]);

      final contract = results[0] as DeployedContract;
      final credentials = results[1] as Credentials;

      // Call the 'startElection' function on the contract
      final ethFunction = contract.function('startElection');
      final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: [name],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );

      print('Election started successfully');
      return result;
    } catch (e) {
      print('Failed to start election: $e');
      rethrow; // Propagate the error
    }
  }

  static Future<String> addCandidate(String name, Web3Client ethClient) async {
    try {
      // Load contract and prepare credentials concurrently using compute
      final List<dynamic> results = await Future.wait([
        compute(_loadContract, null),
        compute(_getCredentials, owner_privatKey),
      ]);

      final contract = results[0] as DeployedContract;
      final credentials = results[1] as Credentials;

      // Call the 'addCandidate' function on the contract
      final ethFunction = contract.function('addCandidate');
      final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: [name],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );

      print('Candidate added successfully');
      return result;
    } catch (e) {
      print('Failed to add candidate: $e');
      rethrow; // Propagate the error
    }
  }

  static Future<String> authorizeVoter(String address, Web3Client ethClient) async {
    try {
      // Load contract and prepare credentials concurrently using compute
      final List<dynamic> results = await Future.wait([
        compute(_loadContract, null),
        compute(_getCredentials, owner_privatKey),
      ]);

      final contract = results[0] as DeployedContract;
      final credentials = results[1] as Credentials;

      // Call the 'authorizeVoter' function on the contract
      final ethFunction = contract.function('authorizeVoter');
      final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: [EthereumAddress.fromHex(address)],
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true,
      );

      print('Voter authorized successfully');
      return result;
    } catch (e) {
      print('Failed to authorize voter: $e');
      rethrow; // Propagate the error
    }
  }

  // Load contract and store it for future use (caching)
  static Future<DeployedContract> _loadContract(void _) async {
    final abi = await rootBundle.loadString('assets/abi.json');
    final contractAddress = contractAddress1;
    return DeployedContract(
      ContractAbi.fromJson(abi, 'Election'),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  // Prepare credentials
  static Future<Credentials> _getCredentials(String privateKey) async {
    return EthPrivateKey.fromHex(privateKey);
  }
}
