class StreamVariant {
  const StreamVariant({
    required this.label,
    required this.url,
    required this.bitrateKbps,
  });

  final String label;
  final String url;
  final int bitrateKbps;
}

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.durationLabel,
    required this.posterUrl,
    required this.price,
    required this.description,
    required this.streams,
  });

  final String id;
  final String title;
  final String genre;
  final String durationLabel;
  final String posterUrl;
  final double price;
  final String description;
  final List<StreamVariant> streams;
}
