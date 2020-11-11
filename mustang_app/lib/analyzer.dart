import 'datareader.dart';

class Analyzer {

  String _teamNum;
  double _noDGames = 0,
      _lightDGames = 0,
      _heavyDGames =
          0; //number of games that team played with NO, LIGHT, or HEAVY defense
  double _noDPts = 0,
      _lightDPts = 0,
      _heavyDPts =
          0; //number of shooting game pieces that went in with NO, LIGHT, or HEAVY defense
  double _ptRankDiff = 0.5,
      _rank = 1,
      _highestRankPossible =
          10; //_ptRankDiff = point difference between an average game to go from 1 rank to the next
  double _noToLightRank = 1,
      _lightToHeavyRank = 1,
      _noPtAvg,
      _lightPtAvg,
      _heavyPtAvg;
  double _zone0Pts,
      _zone1Pts,
      _zone2and3Pts,
      _zone4Pts,
      _zone5Pts,
      _zone6Pts; //regardless of d, total pts scored in all games in each zone

  /*
  Points (_totPts, _noDPts, _lightDPts, _heavyDPts) refers to number of balls/game pieces that successfully went in/increased score, not point value they bring to alliance
	only refers to points gained when defense is feasible (NO AUTO POINTS JUST TELEOP)
	
	Given parameters in calculateRank, rank how easy/hard it is to defend a team 
	 - based on team's counter defense (i.e. how many total balls they score with no/light/heavy defense.
    -> rank 1-10 (1: very good at counter-defending, not worth it to attempt to defend them, 10: defending them will significantly decrease their shooting, definitively go for it)
    -> while rank isn't subjective, the way people interpret a rank is. However, since scouting with a subjective no/light/heavy system, it's important to take actual experience and observations into consideration as well
	 */

  Analyzer(String teamNum) {
    _teamNum = teamNum;

    Map<String, double> noD =
        DataReader.getTeamTargetAverages(_teamNum, "None");
    Map<String, double> lightD =
        DataReader.getTeamTargetAverages(_teamNum, "Light");
    Map<String, double> heavyD =
        DataReader.getTeamTargetAverages(_teamNum, "Heavy");

    //initialize all vars
    _noDGames = DataReader.getTotalNoDGames(_teamNum, "None");
    _noDPts = noD["Tele Balls [Low]"] +
        noD["Tele Balls [1]"] +
        noD["Tele Balls [2/3]"] +
        noD["Tele Balls [4]"] +
        noD["Tele Balls [5]"] +
        noD["Tele Balls [6]"];

    _lightDGames = DataReader.getTotalNoDGames(_teamNum, "Light");
    _lightDPts = lightD["Tele Balls [Low]"] +
        lightD["Tele Balls [1]"] +
        lightD["Tele Balls [2/3]"] +
        lightD["Tele Balls [4]"] +
        lightD["Tele Balls [5]"] +
        lightD["Tele Balls [6]"];

    _heavyDGames = DataReader.getTotalNoDGames(_teamNum, "Heavy");
    _heavyDPts = heavyD["Tele Balls [Low]"] +
        heavyD["Tele Balls [1]"] +
        heavyD["Tele Balls [2/3]"] +
        heavyD["Tele Balls [4]"] +
        heavyD["Tele Balls [5]"] +
        heavyD["Tele Balls [6]"];

    _zone0Pts = noD["Tele Balls [Low]"] +
        lightD["Tele Balls [Low]"] +
        heavyD["Tele Balls [Low]"];
    _zone1Pts = noD["Tele Balls [1]"] +
        lightD["Tele Balls [1]"] +
        heavyD["Tele Balls [1]"];
    _zone2and3Pts = noD["Tele Balls [2/3]"] +
        lightD["Tele Balls [2/3]"] +
        heavyD["Tele Balls [2/3]"];
    _zone4Pts = noD["Tele Balls [4]"] +
        lightD["Tele Balls [4]"] +
        heavyD["Tele Balls [4]"];
    _zone5Pts = noD["Tele Balls [5]"] +
        lightD["Tele Balls [5]"] +
        heavyD["Tele Balls [5]"];
    _zone6Pts = noD["Tele Balls [6]"] +
        lightD["Tele Balls [6]"] +
        heavyD["Tele Balls [6]"];
  }

  String getReport() {
    double rank = calculateRank();
    String optimalDefenseStrategy = calculateOptimalDefenseStrategy();
    String opponentOptimalShootingZone = calculateOptimalZone();

    return "Team: " +
        _teamNum +
        "\ncounter-defense rank (1 - 10): " +
        rank.toString() +
        "\nRecommended Defense Strategy on Team " +
        _teamNum +
        ": " +
        optimalDefenseStrategy +
        "\nTeam " +
        _teamNum +
        " optimal shooting zone: " +
        opponentOptimalShootingZone;
  }

  double calculateRank() {

    _noPtAvg = _noDPts / _noDGames;
    _lightPtAvg = _lightDPts / _lightDGames;
    _heavyPtAvg = _heavyDPts / _heavyDGames;

    //defense is useless, rank = 1
    if (_noPtAvg < _lightPtAvg ||
        _noPtAvg < _heavyPtAvg ||
        _lightPtAvg < _heavyPtAvg) {
      _rank = 1;
      return 1;
    }

    //finds rank of light defense compared to no defense
    for (int i = 1; i < _highestRankPossible; i++) {
      if (_noPtAvg - _lightPtAvg > _ptRankDiff * i) {
        _noToLightRank++;
      }
    }

    //finds rank of heavy defense compared to light defense
    for (int i = 1; i < _highestRankPossible; i++) {
      if (_lightPtAvg - _heavyPtAvg > _ptRankDiff * i) {
        _lightToHeavyRank++;
      }
    }

    //finds rank average of no->light defense and light->heavy defense
    _rank = (_noToLightRank + _lightToHeavyRank) / 2.0;
    return _rank;
  }

  //depending on the rank difference between no, light, and heavy defense, recommends an optimal defense
  //should not be taked too seriously if there aren't enough data points, too many outliers (ex: robot broke down), and this is all based on subjective scouting
  String calculateOptimalDefenseStrategy() {
    if (_rank == 1) {
      return "no defense";
    }
    if (_lightToHeavyRank > _noToLightRank) {
      return "heavy defense";
    }
    if (_lightToHeavyRank < _noToLightRank) {
      return "light defense";
    } else {
      return "";
    }
  }

  //key = teleop in zone x, value = balls scored in zone x, low zone = zone 0
  String calculateOptimalZone() {

    List<double> a = [
      _zone0Pts,
      _zone1Pts,
      _zone2and3Pts,
      _zone4Pts,
      _zone5Pts,
      _zone6Pts
    ];
    double temp;

    for (int i = 0; i < a.length; i++) {
      for (int j = i + 1; j < a.length; j++) {
        if (a[i] > a[j]) {
          temp = a[i];
          a[i] = a[j];
          a[j] = temp;
        }
      }
    }

    double largest = a[a.length - 1];

    if (largest == _zone0Pts) {
      return "zone 0";
    }
    if (largest == _zone1Pts) {
      return "zone 1";
    }
    if (largest == _zone2and3Pts) {
      return "zone 2 and 3";
    }
    if (largest == _zone4Pts) {
      return "zone 4";
    }
    if (largest == _zone5Pts) {
      return "zone 5";
    }
    if (largest == _zone6Pts) {
      return "zone 6";
    } else {
      return null;
    }
  }

  double calculateTotGames() {
    return _noDGames + _lightDGames + _heavyDGames;
  }

  double calculateTotPts() {
    return _noDPts + _lightDPts + _heavyDPts;
  }

  double calcuatePtAvg() {
    return calculateTotPts() / calculateTotGames();
  }

  void addNoDGame(int noDPts) {
    _noDGames++;
    _noDPts += noDPts;
  }

  void addLightDGame(int lightDPts) {
    _lightDGames++;
    _lightDPts += lightDPts;
  }

  void addHeavyDGame(int heavyDPoints) {
    _heavyDGames++;
    _heavyDPts += heavyDPoints;
  }
}
