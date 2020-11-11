import 'dart:async';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataReader {
  static String _data = "";
  static Map<String, dynamic> _averages = {};
  static Map<String, Map<String, dynamic>> _teamAverages = {};
  static List<String> _teams = [];

  DataReader() {
    _averages = {};
    _teamAverages = {};
    _data = "";
    _teams = [];
  }

  static init() async {
    await _readData();
    _updateTeams();
    _calcAverages();
    _calcTeamAverages();
  }

  static String get data {
    return _data;
  }

  static Map<String, dynamic> get averages {
    return _averages;
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

  static double getTotalNoDGames(String teamNumber, String targetType) {
    if (_data.length <= 0) {
      throw new Error();
    }
    double counter = 0;
    List<String> lines = _data.split("\n");
    lines.forEach((element) {
      List<String> values = element.split(',');
      if (values[1].trim() == teamNumber &&
          values[values.length - 1].trim() == targetType) {
        counter++;
      }
    });
    return counter;
  }

  // 11-16
  static Map<String, dynamic> getTeamTargetAverages(
      String teamNumber, String targetType) {
    if (_data.length <= 0) {
      throw new Error();
    }
    Map<String, double> totals = {};
    List<String> lines = _data.split("\n");
    int lineCounter = 1;
    final List<String> keys = lines[0].split(',');
    keys.forEach((key) {
      totals[key] = 0;
    });
    while (lineCounter < lines.length) {
      List<String> values = lines[lineCounter].split(',');
      if (teamNumber == values[1].trim() &&
          values[values.length - 1].trim() == targetType) {
        int index = 0;
        keys.forEach((key) {
          int value = int.parse(values[index].trim(), onError: ((str) {
            return null;
          }));
          if (value != null) {
            totals[key] = totals[key] + value;
          }
          index++;
        });
      }

      lineCounter++;
    }
    return totals;
  }

  static void _updateTeams() {
    if (_data.length <= 0) {
      throw new Error();
    }
    List<String> teams = [];
    List<String> lines = _data.split('\n');
    lines.removeAt(0);
    lines.forEach((element) {
      List<String> values = element.split(',');
      if (!teams.contains(values[1].trim())) {
        teams.add(values[1].trim());
      }
    });
    _teams = teams;
  }

  static String _getCommonStartLocation(String teamNumber) {
    if (_data.length <= 0) {
      throw new Error();
    }
    Map<String, int> counters = {
      "Inline with Opposing Trench": 0,
      "Right of Goal": 0,
      "Left of Goal": 0,
      "Inline with Goal": 0,
      "Inline with Alliance Trench": 0,
    };

    List<String> lines = _data.split('\n');
    lines.forEach((element) {
      List<String> values = element.split(',');
      if (values[1].trim() == teamNumber) {
        counters[values[2].trim()] = counters[values[2].trim()] + 1;
      }
    });
    int max = 0;
    String loc = "Inline with Alliance Trench";
    counters.forEach((key, value) {
      if (value > max) {
        loc = key;
        max = value;
      }
    });
    return loc;
  }

  static String _getCommonEndLocation(String teamNumber) {
    if (_data.length <= 0) {
      throw new Error();
    }
    Map<String, int> counters = {
      "Auto Line": 0,
      "Alliance Trench": 0,
      "Middle": 0,
      "Goal Zone": 0,
      "Goal Side Middle": 0,
      "HP Side Middle": 0,
    };

    List<String> lines = _data.split('\n');
    lines.forEach((element) {
      List<String> values = element.split(',');
      if (values[1].trim() == teamNumber) {
        if (!counters.keys.contains(values[10].trim())) {
          print(values[10].trim());
        }
        counters[values[10].trim()] = counters[values[10].trim()] + 1;
      }
    });
    int max = 0;
    String loc = "Goal Zone";
    counters.forEach((key, value) {
      if (value > max) {
        loc = key;
        max = value;
      }
    });
    return loc;
  }

  static void _calcTeamAverages() {
    if (_data.length <= 0) {
      throw new Error();
    }
    Map<String, Map<String, int>> totals = {};
    Map<String, int> matchCounts = {};
    List<String> lines = _data.split("\n");
    int lineCounter = 1;
    final List<String> keys = lines[0].split(',');

    while (lineCounter < lines.length) {
      List<String> values = lines[lineCounter].split(',');
      String teamNumber = values[1].trim();

      if (totals[teamNumber] == null) {
        matchCounts[teamNumber] = 0;
        totals[teamNumber] = {};
        keys.forEach((key) {
          totals[teamNumber][key] = 0;
        });
      }

      int index = 0;
      keys.forEach((key) {
        int value = int.parse(values[index].trim(), onError: ((str) {
          return null;
        }));
        if (value != null) {
          totals[teamNumber][key] = totals[teamNumber][key] + value;
        }
        index++;
      });
      matchCounts[teamNumber] = matchCounts[teamNumber] + 1;
      lineCounter++;
    }
    _teamAverages = totals.map((teamNumber, data) => MapEntry(
        teamNumber,
        data.map(
            (key, value) => MapEntry(key, value / matchCounts[teamNumber]))));
    _teamAverages.forEach((key, value) {
      _teamAverages[key]["Auto End Location"] = _getCommonEndLocation(key);
      _teamAverages[key]["Starting Location"] = _getCommonStartLocation(key);
    });
  }

  static void _calcAverages() {
    if (_data.length <= 0) {
      throw new Error();
    }
    Map<String, int> totals = {};
    List<String> teams = [];
    List<String> lines = _data.split("\n");
    int lineCounter = 1;
    final List<String> keys = lines[0].split(',');
    keys.forEach((key) {
      totals[key] = 0;
    });
    while (lineCounter < lines.length) {
      List<String> values = lines[lineCounter].split(',');
      if (!teams.contains(values[1].trim())) {
        teams.add(values[1].trim());
      }
      int index = 0;
      keys.forEach((key) {
        int value = int.parse(values[index].trim(), onError: ((str) {
          return null;
        }));
        if (value != null) {
          totals[key] = totals[key] + value;
        }
        index++;
      });
      lineCounter++;
    }
    _averages =
        totals.map((key, value) => MapEntry(key, (value / teams.length)));
  }

  static Future<void> _readData() async {
    _data = await rootBundle.loadString("assets/data.csv");
  }
}
