import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'constants.dart';

class TeamDataAnalyzer {
  static Map<String, Map<String, dynamic>> _teamAverages = {};
  static List<String> _teamNumbers = [];
  static bool _initialized = false;
  static List<DocumentSnapshot> _teams = [];

  static const List<String> keys = [
    'autoBallsLow',
    'autoBalls1',
    'autoBalls23',
    'autoBalls4',
    'autoBalls5',
    'autoBalls6',
    'teleBallsLow',
    'teleBalls1',
    'teleBalls23',
    'teleBalls4',
    'teleBalls5',
    'teleBalls6',
  ];

  static Future<void> init() async {
    _teamNumbers = await getTeamNumbers();

    _teamAverages = await calcAverages();
    _initialized = true;
  }

  static bool get initialized {
    return _initialized;
  }

  static Map<String, Map<String, dynamic>> get teamAverages {
    return _teamAverages;
  }

  static List<String> get teams {
    return _teamNumbers;
  }

  static List<String> get teamNumbers {
    return _teamNumbers;
  }

  static List<DocumentSnapshot> get teamDocs {
    return _teams;
  }

  static DocumentSnapshot getTeamDoc(String teamNumber) {
    return _teams.where((element) => element.documentID == teamNumber).first;
  }

  static Future<List<String>> getTeamNumbers() async {
    _teams = (await Constants.db.collection('teams').getDocuments()).documents;
    List<String> numbers = [];
    _teams.forEach((team) {
      numbers.add(team.documentID);
    });
    return numbers;
  }

  static Map<String, double> getTeamAverage(String teamNumber) {
    return _teamAverages[teamNumber];
  }

  static Future<Map<String, double>> calcTeamAverages(
      String teamNumber, hasAnalysis) async {
    QuerySnapshot matches = await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .getDocuments();

    Map<String, int> totals = {};
    keys.forEach((key) {
      totals[key] = 0;
    });
    if (!hasAnalysis) {
      return totals.map((key, value) => MapEntry(key, -1));
    }
    matches.documents.forEach((match) {
      keys.forEach((key) {
        totals[key] = totals[key] + match.data[key];
      });
    });

    return totals
        .map((key, value) => MapEntry(key, (value / matches.documents.length)));
  }

  static Future<String> getCommonStartLocation(String teamNumber) async {
    QuerySnapshot matches = await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .where('hasAnalysis', isEqualTo: true)
        .getDocuments();
    Map<String, int> counters = {
      "Inline with Opposing Trench": 0,
      "Right of Goal": 0,
      "Left of Goal": 0,
      "Inline with Goal": 0,
      "Inline with Alliance Trench": 0,
      'n/a': 0,
    };

    matches.documents.forEach((element) {
      String key = element.data['startingLocation'];
      counters[key] = counters[key] + 1;
    });
    int max = 0;
    String loc = "n/a";
    counters.forEach((key, value) {
      if (value > max) {
        loc = key;
        max = value;
      }
    });
    return loc;
  }

  static Future<String> getCommonEndLocation(String teamNumber) async {
    QuerySnapshot matches = await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .where('hasAnalysis', isEqualTo: true)
        .getDocuments();

    Map<String, int> counters = {
      "Auto Line": 0,
      "Alliance Trench": 0,
      "Middle": 0,
      "Goal Zone": 0,
      "Goal Side Middle": 0,
      "HP Side Middle": 0,
      'n/a': 0,
    };

    matches.documents.forEach((element) {
      String key = element.data['autoEndLocation'];
      counters[key] = counters[key] + 1;
    });
    int max = 0;
    String loc = "n/a";
    counters.forEach((key, value) {
      if (value > max) {
        loc = key;
        max = value;
      }
    });
    return loc;
  }

  static Future<double> getTotalNoDGames(
      String teamNumber, String targetType) async {
    QuerySnapshot matches = await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .where('hasAnalysis', isEqualTo: true)
        .getDocuments();
    double counter = 0;
    matches.documents.forEach((element) {
      if (element.data['target'] == targetType) {
        counter++;
      }
    });
    return counter;
  }

  static Future<Map<String, double>> getTeamTargetAverages(
      String teamNumber, String targetType) async {
    QuerySnapshot matches = await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .where('hasAnalysis', isEqualTo: true)
        .where('target', isEqualTo: targetType)
        .getDocuments();

    Map<String, int> totals = {};
    keys.forEach((key) {
      totals[key] = 0;
    });

    matches.documents.forEach((match) {
      keys.forEach((key) {
        totals[key] = totals[key] + match.data[key];
      });
    });
    if (matches.documents.length == 0) {
      return totals.map((key, value) => MapEntry(key, -1));
    }
    return totals
        .map((key, value) => MapEntry(key, (value / matches.documents.length)));
  }

  static Future<Map<String, Map<String, dynamic>>> calcAverages() async {
    QuerySnapshot teams = await Constants.db
        .collection('teams')
        // .where('hasAnalysis', isEqualTo: true)
        .getDocuments();
    Map<String, Map<String, double>> averages = {};
    for (int i = 0; i < teams.documents.length; i++) {
      DocumentSnapshot team = teams.documents[i];
      averages[team.documentID] =
          await calcTeamAverages(team.documentID, team.data['hasAnalysis']);
    }
    return averages;
  }

  static Future<StorageTaskSnapshot> exportDB() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/db.json');

    Map<String, Map<String, dynamic>> data = {};
    final Firestore db = Firestore.instance;
    StorageReference ref = FirebaseStorage.instance.ref().child('db.json');
    QuerySnapshot teams = await db.collection('teams').getDocuments();
    teams.documents.forEach((doc) async {
      data[doc.documentID] = {};
      data[doc.documentID]['Match Scouting'] =
          new Map<String, Map<String, dynamic>>();
      data[doc.documentID].addAll(doc.data);
      QuerySnapshot matches =
          await doc.reference.collection('Match Scouting').getDocuments();
      matches.documents.forEach((match) {
        data[doc.documentID]['Match Scouting'][match.documentID] = match.data;
      });
    });

    File updated = await file.writeAsString(jsonEncode(data));
    // File updated = await file.writeAsString("hello");
    return ref.putFile(updated).onComplete;
  }

  // static Future<void> importDB() async { }

  static Future<void> updateDB() async {
    String data = await rootBundle.loadString('assets/data.csv');
    List<String> lines = data.split('\n');
    int lineCounter = 1;
    List<String> dataKeys = lines[0].split(',').map((e) => e.trim()).toList();
    while (lineCounter < lines.length) {
      print('Updating... ' + lineCounter.toString());
      List<String> values =
          lines[lineCounter].split(',').map((e) => e.trim()).toList();
      String teamNumber = values[1], matchNumber = values[0];
      Map<String, dynamic> newMatchData = dataKeys.asMap().map((key, value) {
        dynamic newVal = values[key];
        if (value.contains('Balls') && !value.contains('Acquired') ||
            value.contains('wheel')) {
          newVal = int.parse(newVal);
        }
        return MapEntry(value, newVal);
      });
      newMatchData['hasAnalysis'] = true;
      await Constants.db
          .collection('teams')
          .document(teamNumber)
          .collection('matches')
          .document(matchNumber)
          .updateData(newMatchData);
      lineCounter++;
    }
    // QuerySnapshot teams = await Constants.db
    //     .collection('teams')
    //     .where('hasAnalysis', isEqualTo: true)
    //     .getDocuments();
    // for (int i = 0; i < teams.documents.length; i++) {
    //   DocumentSnapshot team = teams.documents[i];
    //   QuerySnapshot matches =
    //       await team.reference.collection('matches').getDocuments();
    //   for (int j = 0; j < matches.documents.length; j++) {
    //     DocumentSnapshot match = matches.documents[j];
    //     await match.reference.updateData({
    //       'startingLocation': match.data['autoEndLocation'],
    //       'autoEndLocation': match.data['teleBalls1'],
    //       'teleBalls1': 0,
    //       'teleBallsLow': match.data['target'],
    //       'target': match.data['teleBallsLow'],
    //       'autoBallsLow': 0,
    //     });
    //   }
    // }
  }
}
