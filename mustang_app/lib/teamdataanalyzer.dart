import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  static List<DocumentSnapshot> _matches = [];
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
    _teams = (await Constants.db.collection('teams').getDocuments()).documents;
    _matches = (await Constants.db.collectionGroup('matches').getDocuments())
        .documents;
    _updateTeamNumbers();
    _calcAverages();
    _initialized = true;
    Constants.db.collection('teams').snapshots().listen((event) {
      event.documentChanges.forEach((element) {});
      _teams = event.documents;
      _updateTeamNumbers();
      _calcAverages();
    });
    Constants.db.collectionGroup('matches').snapshots().listen((event) {
      _matches = event.documents;
      _updateTeamNumbers();
      _calcAverages();
    });
  }

  static Future<void> refresh() async {
    _initialized = false;
    _teams = (await Constants.db.collection('teams').getDocuments()).documents;
    _matches = (await Constants.db.collectionGroup('matches').getDocuments())
        .documents;
    _updateTeamNumbers();
    _calcAverages();
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

  static List<DocumentSnapshot> get matchDocs {
    return _matches;
  }

  static DocumentSnapshot getTeamDoc(String teamNumber) {
    return _teams
        .where((element) => element.documentID == teamNumber)
        .toList()
        .first;
  }

  static List<DocumentSnapshot> getMatchDocs(String teamNumber) {
    return _matches
        .where((element) => element.data['teamNumber'] == teamNumber)
        .toList();
  }

  static DocumentSnapshot getMatch(String teamNumber, String matchNumber) {
    return _matches
        .where((element) =>
            element.data['teamNumber'] == teamNumber &&
            element.documentID == matchNumber)
        .toList()
        .first;
  }

  static void _updateTeamNumbers() async {
    List<String> numbers = [];
    _teams.forEach((team) {
      numbers.add(team.documentID);
    });
    _teamNumbers = numbers;
  }

  static Map<String, double> getTeamAverage(String teamNumber) {
    return _teamAverages[teamNumber];
  }

  static Map<String, double> _calcTeamAverages(String teamNumber, hasAnalysis) {
    List<DocumentSnapshot> matches = getMatchDocs(teamNumber)
        .where((element) => element.data['hasAnalysis'])
        .toList();

    Map<String, int> totals = {};
    keys.forEach((key) {
      totals[key] = 0;
    });
    if (!hasAnalysis) {
      return totals.map((key, value) => MapEntry(key, -1));
    }
    matches.forEach((match) {
      keys.forEach((key) {
        totals[key] = totals[key] + match.data[key];
      });
    });

    return totals.map((key, value) => MapEntry(key, (value / matches.length)));
  }

  static String getCommonStartLocation(String teamNumber) {
    List<DocumentSnapshot> matches = getMatchDocs(teamNumber)
        .where((element) => element.data['hasAnalysis'])
        .toList();

    Map<String, int> counters = {
      "Inline with Opposing Trench": 0,
      "Right of Goal": 0,
      "Left of Goal": 0,
      "Inline with Goal": 0,
      "Inline with Alliance Trench": 0,
      'n/a': 0,
    };

    matches.forEach((element) {
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

  static String getCommonEndLocation(String teamNumber) {
    List<DocumentSnapshot> matches = getMatchDocs(teamNumber)
        .where((element) => element.data['hasAnalysis'])
        .toList();

    Map<String, int> counters = {
      "Auto Line": 0,
      "Alliance Trench": 0,
      "Middle": 0,
      "Goal Zone": 0,
      "Goal Side Middle": 0,
      "HP Side Middle": 0,
      'n/a': 0,
    };

    matches.forEach((element) {
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

  static double getTotalNoDGames(String teamNumber, String targetType) {
    List<DocumentSnapshot> matches = getMatchDocs(teamNumber)
        .where((element) => element.data['hasAnalysis'])
        .toList();

    double counter = 0;
    matches.forEach((element) {
      if (element.data['target'] == targetType) {
        counter++;
      }
    });
    return counter;
  }

  static Map<String, double> getTeamTargetAverages(
      String teamNumber, String targetType) {
    List<DocumentSnapshot> matches = getMatchDocs(teamNumber)
        .where((element) =>
            element.data['hasAnalysis'] && element.data['target'] == targetType)
        .toList();

    Map<String, int> totals = {};
    keys.forEach((key) {
      totals[key] = 0;
    });

    matches.forEach((match) {
      keys.forEach((key) {
        totals[key] = totals[key] + match.data[key];
      });
    });
    if (matches.length == 0) {
      return totals.map((key, value) => MapEntry(key, -1));
    }
    return totals.map((key, value) => MapEntry(key, (value / matches.length)));
  }

  static void _calcAverages() {
    Map<String, Map<String, double>> averages = {};
    for (int i = 0; i < _teams.length; i++) {
      DocumentSnapshot team = _teams[i];
      averages[team.documentID] =
          _calcTeamAverages(team.documentID, team.data['hasAnalysis']);
    }
    _teamAverages = averages;
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
    return ref.putFile(updated).onComplete;
  }

  // static Future<void> importDB() async { }

  static Future<void> updateDB() async {
    String data = await rootBundle.loadString('assets/data.csv');
    List<String> lines = data.split('\n');
    int lineCounter = 1;
    List<String> dataKeys = lines[0].split(',').map((e) => e.trim()).toList();
    while (lineCounter < lines.length) {
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
