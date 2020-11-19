import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mustang_app/constants.dart';

class ScoutingOperations {
  List<String> teamnames = new List<String>();
  final keys = [
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

  Future<void> startPitScouting(String teamNumber, String names) async {
    await Constants.db.collection('teams').document(teamNumber).setData({
      'driveBaseType': "",
      'innerPort': false,
      'outerPort': false,
      'bottomPort': false,
      'rotationControl': false,
      'positionControl': false,
      'climber': false,
      'leveller': false,
      'notes': "",
      'names': names,
    }, merge: true);
  }

  Future<void> updatePitScouting(String teamNumber,
      {bool inner,
      outer,
      bottom,
      rotation,
      position,
      climb,
      leveller,
      String notes,
      drivebaseType}) async {
    await Constants.db.collection('teams').document(teamNumber).updateData({
      'driveBaseType': drivebaseType,
      'innerPort': inner,
      'outerPort': outer,
      'bottomPort': bottom,
      'rotationControl': rotation,
      'positionControl': position,
      'climber': climb,
      'leveller': leveller,
      'notes': notes
    });
  }

  Future<void> startNewMatch(
      String teamNumber, String matchNumber, String names) async {
    DocumentReference matchDoc = Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber);

    await Constants.db.collection('teams').document(teamNumber).updateData({
      'names': names,
    });
    await matchDoc.setData({
      'auton': {
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'crossedInitiationLine': false,
        'totalPoints': 0,
      },
      'teleop': {
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'rotationControl': false,
        'positionControl': false,
        'totalPoints': 0,
      },
      'endgame': {
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'stagesCompleted': 0,
        'endState': '',
        'totalPoints': 0,
      },
      'summary': {
        'crossedInitiationLine': false,
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'rotationControl': false,
        'positionControl': false,
        'endState': '',
        'result': '',
        'totalPoints': 0,
        'rankingPoints': 0,
        'fouls': 0,
        'comments': '',
        'scouters': '',
        'stagesCompleted': 0,
      }
    }, merge: true);
  }

  Future<void> updateMatchDataAuton(String teamNumber, String matchNumber,
      {int bottomPort = 0,
      int bottomPortMissed = 0,
      int innerPort = 0,
      int innerPortMissed = 0,
      int outerPort = 0,
      int outerPortMissed = 0,
      bool crossedLine = false}) async {
    int totalPoints = bottomPort * 2 + outerPort * 4 + innerPort * 6;
    totalPoints += crossedLine ? 5 : 0;

    await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .updateData({
      'auton': {
        'bottomPort': bottomPort * 2,
        'outerPort': outerPort * 4,
        'innerPort': innerPort * 6,
        'innerPortMissed': innerPortMissed,
        'outerPortMissed': outerPortMissed,
        'bottomPortMissed': bottomPortMissed,
        'crossedInitiationLine': crossedLine,
        'totalPoints': totalPoints,
      }
    });

    await this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  Future<void> updateMatchDataTeleop(String teamNumber, String matchNumber,
      {int bottomPort = 0,
      int bottomPortMissed = 0,
      int innerPort = 0,
      int innerPortMissed = 0,
      int outerPort = 0,
      int outerPortMissed = 0,
      bool rotationControl = false,
      bool positionControl = false}) async {
    int totalPoints = bottomPort * 1 + outerPort * 2 + innerPort * 3;
    totalPoints += rotationControl ? 10 : 0;
    totalPoints += rotationControl ? 20 : 0;

    await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .updateData({
      'teleop': {
        'bottomPort': bottomPort * 1,
        'outerPort': outerPort * 2,
        'innerPort': innerPort * 3,
        'innerPortMissed': innerPortMissed,
        'outerPortMissed': outerPortMissed,
        'bottomPortMissed': bottomPortMissed,
        'rotationControl': rotationControl,
        'positionControl': positionControl,
        'totalPoints': totalPoints,
      }
    });
    await this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  Future<void> updateMatchDataEndgame(String teamNumber, String matchNumber,
      {int bottomPort = 0,
      int bottomPortMissed = 0,
      int innerPort = 0,
      int innerPortMissed = 0,
      int outerPort = 0,
      int outerPortMissed = 0,
      int stagesCompleted = 0,
      String endState = 'Parked'}) async {
    int totalPoints = bottomPort * 1 + outerPort * 2 + innerPort * 3;
    if (endState == 'Parked')
      totalPoints += 5;
    else if (endState == 'Hanging') totalPoints += 25;

    await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .updateData({
      'endgame': {
        'bottomPort': bottomPort * 1,
        'outerPort': outerPort * 2,
        'innerPort': innerPort * 3,
        'innerPortMissed': innerPortMissed,
        'outerPortMissed': outerPortMissed,
        'bottomPortMissed': bottomPortMissed,
        'endState': endState,
        'totalPoints': totalPoints,
        'stagesCompleted': stagesCompleted,
      }
    });
    await this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  Future<void> updateMatchDataEnd(String teamNumber, String matchNumber,
      {String matchResult, int fouls, String finalComments}) async {
    await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .updateData({
      'summary': {
        'result': matchResult,
        'fouls': fouls,
        'comments': finalComments,
      }
    });

    await this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  Future<void> updateMatchDataSummary(
      String teamNumber, String matchNumber) async {
    DocumentSnapshot dataSnapshot = await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .get();
    Map<String, dynamic> map = Map.from(dataSnapshot.data);
    Map<dynamic, dynamic> summary = map['summary'];
    Map<dynamic, dynamic> endgame = map['endgame'];
    Map<dynamic, dynamic> auton = map['auton'];
    Map<dynamic, dynamic> teleop = map['teleop'];
    int rp = 0;
    if (summary['result'] == 'Win')
      rp += 2;
    else if (summary['result'] == 'Draw') rp += 1;
    if (int.parse(endgame['totalPoints'].toString()) >= 65) {
      rp += 1;
    }
    if (int.parse(endgame['stagesCompleted'].toString()) == 3) {
      rp += 1;
    }
    // if (int.parse(summary['stagesCompleted'].toString()) == 3)
    //   rp += 1;
    await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .updateData({
      'summary': {
        'crossedInitiationLine': auton['crossedInitiationLine'],
        'bottomPort': int.parse(auton['bottomPort'].toString()) +
            teleop['bottomPort'] +
            endgame['bottomPort'],
        'bottomPortMissed': int.parse(auton['bottomPortMissed'].toString()) +
            teleop['bottomPortMissed'] +
            endgame['bottomPortMissed'],
        'outerPort': int.parse(auton['outerPort'].toString()) +
            teleop['outerPort'] +
            endgame['outerPort'],
        'outerPortMissed': int.parse(auton['outerPortMissed'].toString()) +
            teleop['outerPortMissed'] +
            endgame['outerPortMissed'],
        'innerPort': int.parse(auton['innerPort'].toString()) +
            teleop['innerPort'] +
            endgame['innerPort'],
        'innerPortMissed': int.parse(auton['innerPortMissed'].toString()) +
            teleop['innerPortMissed'] +
            endgame['innerPortMissed'],
        'rotationControl': teleop['rotationControl'],
        'positionControl': teleop['positionControl'],
        'endState': endgame['endState'],
        'result': summary['result'],
        'totalPoints': int.parse(auton['totalPoints'].toString()) +
            teleop['totalPoints'] +
            endgame['totalPoints'],
        'rankingPoints': rp,
        'fouls': summary['fouls'],
        'comments': summary['comments'],
        'scouters': summary['scouters'],
        'stagesCompleted': summary['stagesCompleted'],
      }
    });
  }

  Future<bool> doesPitDataExist(String teamNumber) async {
    Map<String, dynamic> empty = {
      'driveBaseType': "",
      'innerPort': false,
      'outerPort': false,
      'bottomPort': false,
      'rotationControl': false,
      'positionControl': false,
      'climber': false,
      'leveller': false,
      'notes': "",
      'names': "",
    };
    return await Constants.db
        .collection('teams')
        .document(teamNumber)
        .get()
        .then((onValue) {
      if (onValue == null) {
        return false;
      } else if (onValue.data == empty || onValue.data == null) {
        return false;
      } else {
        return true;
      }
    });
  }

  Future<bool> doesMatchDataExist(String teamNumber, String matchNumber) async {
    Map<String, dynamic> empty = {
      'auton': {
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'crossedInitiationLine': false,
        'totalPoints': 0,
      },
      'teleop': {
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'rotationControl': false,
        'positionControl': false,
        'totalPoints': 0,
      },
      'endgame': {
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'stagesCompleted': 0,
        'endState': '',
        'totalPoints': 0,
      },
      'summary': {
        'crossedInitiationLine': false,
        'bottomPort': 0,
        'outerPort': 0,
        'innerPort': 0,
        'bottomPortMissed': 0,
        'innerPortMissed': 0,
        'outerPortMissed': 0,
        'rotationControl': false,
        'positionControl': false,
        'endState': '',
        'result': '',
        'totalPoints': 0,
        'rankingPoints': 0,
        'fouls': 0,
        'comments': '',
        'stagesCompleted': 0,
      }
    };
    return await Constants.db
        .collection('teams')
        .document(teamNumber)
        .collection('matches')
        .document(matchNumber)
        .get()
        .then((onValue) {
      if (onValue == null) {
        return false;
      } else if (onValue.data == empty || onValue.data == null) {
        return false;
      } else {
        return true;
      }
    });
  }
}
