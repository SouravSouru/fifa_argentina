class PlayerModel {
  final String id;
  final String name;
  final String shortName;
  final String number;
  final String position;
  final String positionCode;
  final String club;
  final String nationality;
  final int age;
  final String imageUrl;
  final Map<String, int> stats;
  final List<String> achievements;
  final int goals;
  final int assists;
  final int matches;
  final double rating;
  final bool isCaptain;
  final bool isStarPlayer;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.number,
    required this.position,
    required this.positionCode,
    required this.club,
    required this.nationality,
    required this.age,
    required this.imageUrl,
    required this.stats,
    required this.achievements,
    required this.goals,
    required this.assists,
    required this.matches,
    required this.rating,
    this.isCaptain = false,
    this.isStarPlayer = false,
  });
}

class MatchModel {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final int homeScore;
  final int awayScore;
  final String date;
  final String venue;
  final String competition;
  final String status;
  final int minute;
  final int homePossession;
  final int awayPossession;
  final int homeShots;
  final int awayShots;
  final int homeCorners;
  final int awayCorners;
  final List<MatchEvent> events;

  const MatchModel({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFlag,
    required this.awayFlag,
    required this.homeScore,
    required this.awayScore,
    required this.date,
    required this.venue,
    required this.competition,
    required this.status,
    required this.minute,
    required this.homePossession,
    required this.awayPossession,
    required this.homeShots,
    required this.awayShots,
    required this.homeCorners,
    required this.awayCorners,
    required this.events,
  });
}

class MatchEvent {
  final int minute;
  final String type; // goal, assist, yellow, red, sub
  final String playerName;
  final bool isHome;

  const MatchEvent({
    required this.minute,
    required this.type,
    required this.playerName,
    required this.isHome,
  });
}
