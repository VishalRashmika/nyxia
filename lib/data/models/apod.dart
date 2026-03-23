/// data model for apod
class Apod {
  final String title;
  final String date;
  final String explanation;
  final String url;
  final String? hdUrl;
  final String mediaType;
  final String? copyright;

  Apod({
    required this.title,
    required this.date,
    required this.explanation,
    required this.url,
    this.hdUrl,
    required this.mediaType,
    this.copyright,
  });

  factory Apod.fromJson(Map<String, dynamic> json) {
    return Apod(
      title: json['title'] ?? 'Untitled',
      date: json['date'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      hdUrl: json['hdurl'],
      mediaType: json['media_type'] ?? 'image',
      copyright: json['copyright'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'explanation': explanation,
      'url': url,
      'hdurl': hdUrl,
      'media_type': mediaType,
      'copyright': copyright,
    };
  }
}
