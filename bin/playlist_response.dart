class PlaylistResponse {
  late Metadata metadata;
  late List<PlaylistItem> items;

  PlaylistResponse({required this.metadata, required this.items});

  PlaylistResponse.fromJson(Map<String, dynamic> json) {
    var jsonMetadata = json['data']['attributes']['metadata'];
    var jsonItems = json['data']['attributes']['items'];
    metadata = Metadata.fromJson(jsonMetadata);
    items = <PlaylistItem>[];
    if (jsonItems != null) {
      for (var v in (jsonItems as List)) {
        items.add(PlaylistItem.fromJson(v));
      }
    }
  }
}

class Metadata {
  String? providerId;
  String? language;
  String? title;
  String? subtitle;
  String? description;
  List<Images>? images;
  ItemLink? link;
  ItemConfig? config;
  Duration? duration;
  bool? episodic;

  Metadata(
      {this.providerId,
      this.language,
      this.title,
      this.subtitle,
      this.description,
      this.images,
      this.link,
      this.config,
      this.duration,
      this.episodic});

  Metadata.fromJson(Map<String, dynamic> json) {
    providerId = json['providerId'];
    language = json['language'];
    title = json['title'];
    subtitle = json['subtitle'];
    description = json['description'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    link = json['link'] != null ? ItemLink.fromJson(json['link']) : null;
    config =
        json['config'] != null ? ItemConfig.fromJson(json['config']) : null;
    duration = json['duration'] != null
        ? Duration(seconds: json['duration']['seconds'])
        : null;
    episodic = json['episodic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['providerId'] = providerId;
    data['language'] = language;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['description'] = description;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (link != null) {
      data['link'] = link!.toJson();
    }
    if (config != null) {
      data['config'] = config!.toJson();
    }
    if (duration != null) {
      data['duration'] = duration!.inSeconds;
    }
    data['episodic'] = episodic;
    return data;
  }
}

class Images {
  String? caption;
  String? url;

  Images({this.caption, this.url});

  Images.fromJson(Map<String, dynamic> json) {
    caption = json['caption'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['caption'] = caption;
    data['url'] = url;
    return data;
  }
}

class PlaylistItem {
  String? providerId;
  String? title;
  String? subtitle;
  List<Images>? images;
  ItemLink? link;
  ItemConfig? config;
  Duration? duration;
  bool? current;
  bool? live;
  dynamic beginRounded;
  String? description;

  PlaylistItem({
    this.providerId,
    this.title,
    this.subtitle,
    this.images,
    this.link,
    this.config,
    this.duration,
    this.current,
    this.live,
    this.beginRounded,
    this.description,
  });

  PlaylistItem.fromJson(Map<String, dynamic> json) {
    providerId = json['providerId'];
    title = json['title'];
    subtitle = json['subtitle'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    link = json['link'] != null ? ItemLink.fromJson(json['link']) : null;
    config =
        json['config'] != null ? ItemConfig.fromJson(json['config']) : null;
    duration = json['duration'] != null
        ? Duration(seconds: json['duration']['seconds'])
        : null;
    current = json['current'];
    live = json['live'];
    beginRounded = json['beginRounded'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['providerId'] = providerId;
    data['title'] = title;
    data['subtitle'] = subtitle;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (link != null) {
      data['link'] = link!.toJson();
    }
    if (config != null) {
      data['config'] = config!.toJson();
    }
    if (duration != null) {
      data['duration'] = duration!.inSeconds;
    }
    data['current'] = current;
    data['live'] = live;
    data['beginRounded'] = beginRounded;
    data['description'] = description;
    return data;
  }
}

class ItemLink {
  String? url;
  String? deeplink;
  dynamic videoOnDemand;

  ItemLink({this.url, this.deeplink, this.videoOnDemand});

  ItemLink.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    deeplink = json['deeplink'];
    videoOnDemand = json['videoOnDemand'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['deeplink'] = deeplink;
    data['videoOnDemand'] = videoOnDemand;
    return data;
  }
}

class ItemConfig {
  String? url;
  String? replay;
  String? playlist;

  ItemConfig({this.url, this.replay, this.playlist});

  ItemConfig.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    replay = json['replay'];
    playlist = json['playlist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['replay'] = replay;
    data['playlist'] = playlist;
    return data;
  }
}
