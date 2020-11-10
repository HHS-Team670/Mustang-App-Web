import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseOperations {
  Firestore db;
  List<String> teamNames = new List<String>();

  DatabaseOperations() {
    // DBRef = FirebaseDatabase.instance.reference();
    db = Firestore.instance;
  }

  void startPitScouting(String teamNumber, String names) {
    db.collection('teams').document('Team Number: ' + teamNumber).setData({
      'Pit Scouting': {
        'Drivebase Type': "",
        'Inner Port': false,
        'Outer Port': false,
        'Bottom Port': false,
        'Rotation Control': false,
        'Position Control': false,
        'Climber': false,
        'Leveller': false,
        'Notes': "",
      },
      'Names': names,
    }, merge: true);
    db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .updateData({'Team Number': teamNumber});
  }

  void updatePitScouting(String teamNumber,
      {bool inner,
      outer,
      bottom,
      rotation,
      position,
      climb,
      leveller,
      String notes,
      drivebaseType}) {
    db.collection('teams').document('Team Number: ' + teamNumber).updateData({
      'Pit Scouting': {
        'Drivebase Type': drivebaseType,
        'Inner Port': inner,
        'Outer Port': outer,
        'Bottom Port': bottom,
        'Rotation Control': rotation,
        'Position Control': position,
        'Climber': climb,
        'Leveller': leveller,
        'Notes': notes
      }
    });
  }

  void startNewMatch(String teamNumber, String matchNumber, String names) {
    var parent = db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber);
    db.collection('teams').document('Team Number: ' + teamNumber).updateData({
      'Names': names,
    });
    parent.setData({
      'Auton': {},
      'Teleop': {},
      'Endgame': {},
      'Summary': {},
    }, merge: true);
    parent.setData({
      'Auton': {
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Crossed Initiation Line': false,
        'Total Points': 0,
      }
    }, merge: true);
    parent.setData({
      'Teleop': {
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Rotation Control': false,
        'Position Control': false,
        'Total Points': 0,
      }
    }, merge: true);
    parent.setData({
      'Endgame': {
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Stages Completed': 0,
        'Ending State': '',
        'Total Points': 0,
      }
    }, merge: true);
    parent.setData({
      'Summary': {
        'Crossed Initiation Line': false,
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Rotation Control': false,
        'Position Control': false,
        'Ending State': '',
        'Match Result': '',
        'Total Points': 0,
        'Ranking Points': 0,
        'Fouls': 0,
        'Final Comments': '',
        'Scouters': '',
        'Stages Completed': 0,
      }
    }, merge: true);
  }

  void updateMatchDataAuton(String teamNumber, String matchNumber,
      {int bottomPort = 0,
      int bottomPortMissed,
      int innerPort,
      int innerPortMissed,
      int outerPort,
      int outerPortMissed,
      bool crossedLine}) {
    int totalPoints = bottomPort * 2 + outerPort * 4 + innerPort * 6;
    totalPoints += crossedLine ? 5 : 0;

    db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber)
        .updateData({
      'Auton': {
        'Bottom Port': bottomPort * 2,
        'Outer Port': outerPort * 4,
        'Inner Port': innerPort * 6,
        'Inner Port Missed': innerPortMissed,
        'Outer Port Missed': outerPortMissed,
        'Bottom Port Missed': bottomPortMissed,
        'Crossed Initiation Line': crossedLine,
        'Total Points': totalPoints,
      }
    });
    this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  void updateMatchDataTeleop(String teamNumber, String matchNumber,
      {int bottomPort = 0,
      int bottomPortMissed,
      int innerPort,
      int innerPortMissed,
      int outerPort,
      int outerPortMissed,
      bool rotationControl,
      bool positionControl}) {
    int totalPoints = bottomPort * 1 + outerPort * 2 + innerPort * 3;
    totalPoints += rotationControl ? 10 : 0;
    totalPoints += rotationControl ? 20 : 0;

    db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber)
        .updateData({
      'Teleop': {
        'Bottom Port': bottomPort * 1,
        'Outer Port': outerPort * 2,
        'Inner Port': innerPort * 3,
        'Inner Port Missed': innerPortMissed,
        'Outer Port Missed': outerPortMissed,
        'Bottom Port Missed': bottomPortMissed,
        'Rotation Control': rotationControl,
        'Position Control': positionControl,
        'Total Points': totalPoints,
      }
    });
    this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  void updateMatchDataEndgame(String teamNumber, String matchNumber,
      {int bottomPort = 0,
      int bottomPortMissed,
      int innerPort,
      int innerPortMissed,
      int outerPort,
      int outerPortMissed,
      int stagesCompleted,
      String endState}) {
    int totalPoints = bottomPort * 1 + outerPort * 2 + innerPort * 3;
    if (endState == 'Parked')
      totalPoints += 5;
    else if (endState == 'Hanging') totalPoints += 25;

    db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber)
        .updateData({
      'Endgame': {
        'Bottom Port': bottomPort * 1,
        'Outer Port': outerPort * 2,
        'Inner Port': innerPort * 3,
        'Inner Port Missed': innerPortMissed,
        'Outer Port Missed': outerPortMissed,
        'Bottom Port Missed': bottomPortMissed,
        'Ending State': endState,
        'Total Points': totalPoints,
        'Stages Completed': stagesCompleted,
      }
    });
    this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  void updateMatchDataEnd(String teamNumber, String matchNumber,
      {String matchResult, int fouls, String finalComments}) {
    db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber)
        .updateData({
      'Summary': {
        'Match Result': matchResult,
        'Fouls': fouls,
        'Final Comments': finalComments,
      }
    });

    this.updateMatchDataSummary(teamNumber, matchNumber);
  }

  void updateMatchDataSummary(String teamNumber, String matchNumber) {
    db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber)
        .get()
        .then((DocumentSnapshot dataSnapshot) {
      var map = dataSnapshot.data.map((String key, Object value) {
        return MapEntry(key, value);
      });
      Map<dynamic, dynamic> summary = map['Summary'];
      Map<dynamic, dynamic> endgame = map['Endgame'];
      Map<dynamic, dynamic> auton = map['Auton'];
      Map<dynamic, dynamic> teleop = map['Teleop'];
      var rp = 0;
      if (summary['Match Result'] == 'Win')
        rp += 2;
      else if (summary['Match Result'] == 'Draw') rp += 1;
      if (int.parse(endgame['Total Points'].toString()) >= 65) {
        rp += 1;
      }
      if (int.parse(endgame['Stages Completed'].toString()) == 3) {
        rp += 1;
      }
      // if (int.parse(summary['Stages Completed'].toString()) == 3)
      //   rp += 1;
      db
          .collection('teams')
          .document('Team Number: ' + teamNumber)
          .collection('Match Scouting')
          .document('Match Number: ' + matchNumber)
          .updateData({
        'Summary': {
          'Crossed Initiation Line': auton['Crossed Initiation Line'],
          'Bottom Port': int.parse(auton['Bottom Port'].toString()) +
              teleop['Bottom Port'] +
              endgame['Bottom Port'],
          'Bottom Port Missed':
              int.parse(auton['Bottom Port Missed'].toString()) +
                  teleop['Bottom Port Missed'] +
                  endgame['Bottom Port Missed'],
          'Outer Port': int.parse(auton['Outer Port'].toString()) +
              teleop['Outer Port'] +
              endgame['Outer Port'],
          'Outer Port Missed':
              int.parse(auton['Outer Port Missed'].toString()) +
                  teleop['Outer Port Missed'] +
                  endgame['Outer Port Missed'],
          'Inner Port': int.parse(auton['Inner Port'].toString()) +
              teleop['Inner Port'] +
              endgame['Inner Port'],
          'Inner Port Missed':
              int.parse(auton['Inner Port Missed'].toString()) +
                  teleop['Inner Port Missed'] +
                  endgame['Inner Port Missed'],
          'Rotation Control': teleop['Rotation Control'],
          'Position Control': teleop['Position Control'],
          'Ending State': endgame['Ending State'],
          'Match Result': summary['Match Result'],
          'Total Points': int.parse(auton['Total Points'].toString()) +
              teleop['Total Points'] +
              endgame['Total Points'],
          'Ranking Points': rp,
          'Fouls': summary['Fouls'],
          'Final Comments': summary['Final Comments'],
          'Scouters': summary['Scouters'],
          'Stages Completed': summary['Stages Completed'],
        }
      });
    });
  }

  Future<bool> doesPitDataExist(String teamNumber) async {
    Map<String, dynamic> empty = {
      "Pit Scouting": {
        'Drivebase Type': "",
        'Inner Port': false,
        'Outer Port': false,
        'Bottom Port': false,
        'Rotation Control': false,
        'Position Control': false,
        'Climber': false,
        'Leveller': false,
        'Notes': "",
      },
      'Names': "",
    };
    return await db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
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
      'Auton': {
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Crossed Initiation Line': false,
        'Total Points': 0,
      },
      'Teleop': {
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Rotation Control': false,
        'Position Control': false,
        'Total Points': 0,
      },
      'Endgame': {
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Stages Completed': 0,
        'Ending State': '',
        'Total Points': 0,
      },
      'Summary': {
        'Crossed Initiation Line': false,
        'Bottom Port': 0,
        'Outer Port': 0,
        'Inner Port': 0,
        'Bottom Port Missed': 0,
        'Inner Port Missed': 0,
        'Outer Port Missed': 0,
        'Rotation Control': false,
        'Position Control': false,
        'Ending State': '',
        'Match Result': '',
        'Total Points': 0,
        'Ranking Points': 0,
        'Fouls': 0,
        'Final Comments': '',
        'Stages Completed': 0,
      }
    };
    return await db
        .collection('teams')
        .document('Team Number: ' + teamNumber)
        .collection('Match Scouting')
        .document('Match Number: ' + matchNumber)
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
