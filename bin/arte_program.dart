class ArteProgram {
  String id;
  String? programId;
  String? type;
  ArteKind? kind;
  String? url;
  String? deeplink;
  String? title;
  String? subtitle;
  String? shortDescription;
  ArteImage? mainImage;
  List<ArteSticker>? stickers;
  String? trackingPixel;
  String? teaserText;
  int? duration;
  String? durationLabel;
  ArteGeoblocking? geoblocking;
  List<Map<String, dynamic>>? audioVersions;
  ArteAvailability? availability;
  int? ageRating;
  String? callToAction;
  dynamic clip;
  dynamic trailer;
  int? childrenCount;

  ArteProgram({
    required this.id,
    this.programId,
    this.type,
    this.kind,
    this.url,
    this.deeplink,
    this.title,
    this.subtitle,
    this.shortDescription,
    this.mainImage,
    this.stickers,
    this.trackingPixel,
    this.teaserText,
    this.duration,
    this.durationLabel,
    this.geoblocking,
    this.audioVersions,
    this.availability,
    this.ageRating,
    this.callToAction,
    this.clip,
    this.trailer,
    this.childrenCount,
  });

  bool isFilm() {
    if (programId == null) return false;
    var parts = programId!.split('-');
    if (parts.length != 3) return false; // invalid id
    if (parts[0].length != 6) return false; // first part lenght
    if (parts[1].length != 3) return false; // second part lenght
    if (parts[2].length != 1) return false; // last part lenght
    if (int.parse(parts[1]) != 0) return false; // not a movie
    return true;
  }

  bool isEpisode() {
    if (programId == null) return false;
    var parts = programId!.split('-');
    if (parts.length != 3) return false; // invalid id
    if (parts[0].length != 6) return false; // first part lenght
    if (parts[1].length != 3) return false; // second part lenght
    if (parts[2].length != 1) return false; // last part lenght
    if (int.parse(parts[1]) <= 0) return false; // not an episode
    return true;
  }

  factory ArteProgram.fromJson(Map<String, dynamic> json) {
    return ArteProgram(
      id: json['id'],
      type: json['type'],
      kind: json['kind'] != null ? ArteKind.fromJson(json['kind']) : null,
      url: json['url'],
      deeplink: json['deeplink'],
      title: json['title'],
      subtitle: json['subtitle'],
      shortDescription: json['shortDescription'],
      mainImage: json['mainImage'] != null
          ? ArteImage.fromJson(json['mainImage'])
          : null,
      stickers: json['stickers'] != null
          ? List<ArteSticker>.from(
              json['stickers'].map((x) => ArteSticker.fromJson(x)))
          : null,
      trackingPixel: json['trackingPixel'],
      programId: json['programId'],
      teaserText: json['teaserText'],
      duration: json['duration'],
      durationLabel: json['durationLabel'],
      geoblocking: json['geoblocking'] != null
          ? ArteGeoblocking.fromJson(json['geoblocking'])
          : null,
      audioVersions: json['audioVersions'] != null
          ? List<Map<String, dynamic>>.from(json['audioVersions'].map((x) => x))
          : null,
      availability: json['availability'] != null
          ? ArteAvailability.fromJson(json['availability'])
          : null,
      ageRating: json['ageRating'],
      callToAction: json['callToAction'],
      clip: json['clip'],
      trailer: json['trailer'],
      childrenCount: json['childrenCount'],
    );
  }
}

class ArteKind {
  String code;
  String label;
  bool isCollection;

  ArteKind({
    required this.code,
    required this.label,
    required this.isCollection,
  });

  factory ArteKind.fromJson(Map<String, dynamic> json) {
    return ArteKind(
      code: json['code'],
      label: json['label'],
      isCollection: json['isCollection'],
    );
  }
}

class ArteImage {
  dynamic caption;
  String url;

  ArteImage({
    required this.caption,
    required this.url,
  });

  factory ArteImage.fromJson(Map<String, dynamic> json) {
    return ArteImage(
      caption: json['caption'],
      url: json['url'],
    );
  }
}

class ArteSticker {
  String code;
  String label;

  ArteSticker({
    required this.code,
    required this.label,
  });

  factory ArteSticker.fromJson(Map<String, dynamic> json) {
    return ArteSticker(
      code: json['code'],
      label: json['label'],
    );
  }
}

class ArteGeoblocking {
  String code;
  String label;
  List<dynamic> inclusion;
  List<dynamic> exclusion;

  ArteGeoblocking({
    required this.code,
    required this.label,
    required this.inclusion,
    required this.exclusion,
  });

  factory ArteGeoblocking.fromJson(Map<String, dynamic> json) {
    return ArteGeoblocking(
      code: json['code'],
      label: json['label'],
      inclusion: List<dynamic>.from(json['inclusion'].map((x) => x)),
      exclusion: List<dynamic>.from(json['exclusion'].map((x) => x)),
    );
  }
}

class ArteAvailability {
  String type;
  String start;
  String end;
  String upcomingDate;
  dynamic label;

  ArteAvailability({
    required this.type,
    required this.start,
    required this.end,
    required this.upcomingDate,
    required this.label,
  });

  factory ArteAvailability.fromJson(Map<String, dynamic> json) {
    return ArteAvailability(
      type: json['type'],
      start: json['start'],
      end: json['end'],
      upcomingDate: json['upcomingDate'],
      label: json['label'],
    );
  }
}
