class ClubRun {
  const ClubRun({
    required this.id,
    required this.title,
    required this.time,
    required this.meetingPoint,
    required this.pace,
    required this.host,
    required this.club,
    required this.joined,
    required this.spots,
    this.isTonight = false,
  });

  final String id;
  final String title;
  final String time;
  final String meetingPoint;
  final String pace;
  final String host;
  final String club;
  final int joined;
  final int spots;
  final bool isTonight;
}

class RunningClub {
  const RunningClub({
    required this.name,
    required this.city,
    required this.members,
    required this.nextRun,
    required this.initials,
  });

  final String name;
  final String city;
  final int members;
  final String nextRun;
  final String initials;
}

class PastRunMemory {
  const PastRunMemory({
    required this.title,
    required this.date,
    required this.crew,
    required this.city,
    required this.distance,
  });

  final String title;
  final String date;
  final String crew;
  final String city;
  final String distance;
}

const demoClub = RunningClub(
  name: 'Casa Run Crew',
  city: 'Casablanca',
  members: 48,
  nextRun: 'Wed · 6:00 AM',
  initials: 'CR',
);

const demoRuns = <ClubRun>[
  ClubRun(
    id: '1',
    title: 'Sunset loop',
    time: '6:30 PM',
    meetingPoint: 'Place Mohammed V',
    pace: '5:30 /km · easy',
    host: 'Youssef',
    club: 'Casa Run Crew',
    joined: 12,
    spots: 20,
    isTonight: true,
  ),
  ClubRun(
    id: '2',
    title: 'Corniche tempo',
    time: '7:00 AM',
    meetingPoint: 'Ain Diab beach',
    pace: '4:45 /km',
    host: 'Sara',
    club: 'Casa Run Crew',
    joined: 8,
    spots: 15,
  ),
  ClubRun(
    id: '3',
    title: 'Old Medina easy run',
    time: '6:00 PM',
    meetingPoint: 'Marché Central',
    pace: '6:00 /km · social',
    host: 'Karim',
    club: 'Maarif Runners',
    joined: 5,
    spots: 12,
  ),
];

const demoMemory = PastRunMemory(
  title: 'Friday night crew run',
  date: 'Fri, Jun 27',
  crew: 'Casa Run Crew',
  city: 'Casablanca',
  distance: '8.2 km',
);
