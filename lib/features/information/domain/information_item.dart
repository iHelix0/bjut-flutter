class InformationItem {
  const InformationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.updatedAt,
    required this.sourceUrl,
    this.links = const <InformationLink>[],
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final DateTime updatedAt;
  final String sourceUrl;
  final List<InformationLink> links;

  factory InformationItem.fromJson(Map<String, dynamic> json) {
    final rawLinks = json['links'];
    final links = rawLinks is List
        ? rawLinks
              .whereType<Map<String, dynamic>>()
              .map(InformationLink.fromJson)
              .toList(growable: false)
        : const <InformationLink>[];

    return InformationItem(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      category: _requiredString(json, 'category'),
      body: _requiredString(json, 'body'),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')),
      sourceUrl: _requiredString(json, 'sourceUrl'),
      links: links,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('information field "$key" is required');
    }
    return value;
  }
}

class InformationLink {
  const InformationLink({required this.label, required this.url});

  final String label;
  final String url;

  factory InformationLink.fromJson(Map<String, dynamic> json) {
    final label = json['label'];
    final url = json['url'];
    if (label is! String ||
        label.trim().isEmpty ||
        url is! String ||
        url.trim().isEmpty) {
      throw const FormatException('information link requires label and url');
    }
    return InformationLink(label: label, url: url);
  }
}
