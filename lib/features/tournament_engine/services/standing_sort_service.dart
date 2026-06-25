import '../../standings/models/group_standing.dart';

class StandingSortService {
  List<GroupStanding> sortGroupStandings(List<GroupStanding> standings) {
    final list = List<GroupStanding>.from(standings);
    list.sort((a, b) {
      if (b.points != a.points) {
        return b.points.compareTo(a.points);
      }
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      if (b.goalsFor != a.goalsFor) {
        return b.goalsFor.compareTo(a.goalsFor);
      }
      return a.team.name.en.compareTo(b.team.name.en);
    });
    return list;
  }

  List<GroupStanding> sortThirdPlaces(List<GroupStanding> thirdPlaces) {
    return sortGroupStandings(thirdPlaces);
  }
}
