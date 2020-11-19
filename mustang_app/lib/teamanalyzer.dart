import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class TeamAnalyzer {
  static Map<String, Map<String, dynamic>> _teamAverages = {};
  static List<String> _teams = [];
  static Firestore _db = Firestore.instance;
  static bool _initialized = false;

  static const List<String> keys = [
    'startingLocation',
    'autoBallsLow',
    'autoBalls1',
    'autoBalls23',
    'autoBalls4',
    'autoBalls5',
    'autoBalls6',
    'autoBallsAcquired',
    'autoEndLocation',
    'teleBallsLow',
    'teleBalls1',
    'teleBalls23',
    'teleBalls4',
    'teleBalls5',
    'teleBalls6',
    'wheelSpin',
    'wheelColorMatch',
    'defender',
    'target'
  ];

  static Future<void> init() async {
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
    return _teams;
  }

  static Map<String, double> getTeamAverage(String teamNumber) {
    return _teamAverages[teamNumber];
  }

  static Future<Map<String, double>> calcTeamAverages(String teamNumber) async {
    QuerySnapshot matches = await _db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .where('hasAnalysis', isEqualTo: true)
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
      return totals.map((key, value) => MapEntry(key, value.toDouble()));
    }
    return totals
        .map((key, value) => MapEntry(key, (value / matches.documents.length)));
  }

  static Future<String> getCommonStartLocation(String teamNumber) async {
    QuerySnapshot matches = await _db
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
    QuerySnapshot matches = await _db
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
    QuerySnapshot matches = await _db
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

  static Future<Map<String, dynamic>> getTeamTargetAverages(
      String teamNumber, String targetType) async {
    QuerySnapshot matches = await _db
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
      return totals.map((key, value) => MapEntry(key, value.toDouble()));
    }
    return totals
        .map((key, value) => MapEntry(key, (value / matches.documents.length)));
  }

  static Future<Map<String, Map<String, double>>> calcAverages() async {
    QuerySnapshot teams = await _db
        .collection('teams')
        .where('hasAnalysis', isEqualTo: true)
        .getDocuments();
    Map<String, Map<String, double>> averages = {};
    for (int i = 0; i < teams.documents.length; i++) {
      DocumentSnapshot team = teams.documents[i];
      averages[team.documentID] = await calcTeamAverages(team.documentID);
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
}
