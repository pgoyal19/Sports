import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class BlockchainTransaction {
  final String hash;
  final String athleteId;
  final String testType;
  final Map<String, dynamic> testData;
  final DateTime timestamp;
  final String blockNumber;
  final bool verified;

  BlockchainTransaction({
    required this.hash,
    required this.athleteId,
    required this.testType,
    required this.testData,
    required this.timestamp,
    required this.blockNumber,
    this.verified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'athleteId': athleteId,
      'testType': testType,
      'testData': testData,
      'timestamp': timestamp.toIso8601String(),
      'blockNumber': blockNumber,
      'verified': verified,
    };
  }

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      hash: json['hash'],
      athleteId: json['athleteId'],
      testType: json['testType'],
      testData: Map<String, dynamic>.from(json['testData']),
      timestamp: DateTime.parse(json['timestamp']),
      blockNumber: json['blockNumber'],
      verified: json['verified'] ?? false,
    );
  }
}

class NFTBadge {
  final String tokenId;
  final String name;
  final String description;
  final String imageUrl;
  final String rarity;
  final DateTime mintedAt;
  final String transactionHash;

  NFTBadge({
    required this.tokenId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rarity,
    required this.mintedAt,
    required this.transactionHash,
  });
}

class BlockchainProvider extends ChangeNotifier {
  List<BlockchainTransaction> _transactions = [];
  List<NFTBadge> _nftBadges = [];
  bool _isConnected = false;
  String? _walletAddress;

  List<BlockchainTransaction> get transactions => _transactions;
  List<NFTBadge> get nftBadges => _nftBadges;
  bool get isConnected => _isConnected;
  String? get walletAddress => _walletAddress;

  // Simulate blockchain connection
  Future<void> connectWallet() async {
    // In a real implementation, this would connect to a Web3 wallet
    await Future.delayed(const Duration(seconds: 2));
    _isConnected = true;
    _walletAddress = "0x${_generateRandomHex(40)}";
    notifyListeners();
  }

  // Record test result on blockchain
  Future<String> recordTestResult({
    required String athleteId,
    required String testType,
    required Map<String, dynamic> testData,
  }) async {
    try {
      // Generate hash from test data
      final dataString = jsonEncode({
        'athleteId': athleteId,
        'testType': testType,
        'testData': testData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      final bytes = utf8.encode(dataString);
      final digest = sha256.convert(bytes);
      final hash = digest.toString();

      // Simulate blockchain transaction
      final transaction = BlockchainTransaction(
        hash: hash,
        athleteId: athleteId,
        testType: testType,
        testData: testData,
        timestamp: DateTime.now(),
        blockNumber: _generateRandomHex(8),
      );

      _transactions.add(transaction);
      
      // Simulate verification delay
      await Future.delayed(const Duration(seconds: 3));
      
      // Mark as verified
      final verifiedTransaction = BlockchainTransaction(
        hash: hash,
        athleteId: athleteId,
        testType: testType,
        testData: testData,
        timestamp: transaction.timestamp,
        blockNumber: transaction.blockNumber,
        verified: true,
      );
      
      final index = _transactions.indexWhere((t) => t.hash == hash);
      if (index != -1) {
        _transactions[index] = verifiedTransaction;
      }

      notifyListeners();
      return hash;
    } catch (e) {
      throw Exception('Failed to record on blockchain: $e');
    }
  }

  // Mint NFT badge
  Future<String> mintNFTBadge({
    required String name,
    required String description,
    required String imageUrl,
    required String rarity,
  }) async {
    try {
      final tokenId = _generateRandomHex(16);
      final transactionHash = _generateRandomHex(64);

      final nftBadge = NFTBadge(
        tokenId: tokenId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        rarity: rarity,
        mintedAt: DateTime.now(),
        transactionHash: transactionHash,
      );

      _nftBadges.add(nftBadge);
      notifyListeners();

      return transactionHash;
    } catch (e) {
      throw Exception('Failed to mint NFT: $e');
    }
  }

  // Verify transaction
  Future<bool> verifyTransaction(String hash) async {
    try {
      // Simulate blockchain verification
      await Future.delayed(const Duration(seconds: 1));
      
      final transaction = _transactions.firstWhere(
        (t) => t.hash == hash,
        orElse: () => throw Exception('Transaction not found'),
      );

      return transaction.verified;
    } catch (e) {
      return false;
    }
  }

  // Get athlete's transaction history
  List<BlockchainTransaction> getAthleteTransactions(String athleteId) {
    return _transactions.where((t) => t.athleteId == athleteId).toList();
  }

  // Get athlete's NFT badges
  List<NFTBadge> getAthleteNFTs(String athleteId) {
    // In a real implementation, this would filter by athlete ID
    return _nftBadges;
  }

  // Generate random hex string
  String _generateRandomHex(int length) {
    final random = DateTime.now().millisecondsSinceEpoch;
    return random.toRadixString(16).padLeft(length, '0').substring(0, length);
  }

  // Simulate federated learning contribution
  Future<void> contributeToFederatedLearning({
    required Map<String, dynamic> learningData,
  }) async {
    try {
      // In a real implementation, this would send encrypted learning data
      // to a federated learning server
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate contribution reward
      if (kDebugMode) {
        print('Federated learning contribution recorded');
      }
    } catch (e) {
      throw Exception('Failed to contribute to federated learning: $e');
    }
  }

  void disconnect() {
    _isConnected = false;
    _walletAddress = null;
    notifyListeners();
  }
}
