import 'movie.dart';

class MovieRepository {
  const MovieRepository();

  List<Movie> fetchTrending() {
    const low = StreamVariant(
      label: 'Data saver',
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      bitrateKbps: 600,
    );
    const medium = StreamVariant(
      label: 'Balanced',
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      bitrateKbps: 1400,
    );
    const high = StreamVariant(
      label: 'HD',
      url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      bitrateKbps: 2600,
    );

    return const [
      Movie(
        id: 'edge-of-galaxy',
        title: 'Edge of Galaxy',
        genre: 'Sci‑Fi',
        durationLabel: '2h 08m',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=900',
        price: 4.99,
        description:
            'A deep-space rescue team races to stop a rogue AI before Earth loses communication forever.',
        streams: [low, medium, high],
      ),
      Movie(
        id: 'silent-district',
        title: 'Silent District',
        genre: 'Thriller',
        durationLabel: '1h 52m',
        posterUrl: 'https://images.unsplash.com/photo-1489599162163-3fb4b9cbf2db?w=900',
        price: 3.49,
        description:
            'A detective enters a city zone where no one can speak, and every clue is visual.',
        streams: [low, medium, high],
      ),
      Movie(
        id: 'sunrise-protocol',
        title: 'Sunrise Protocol',
        genre: 'Action',
        durationLabel: '2h 20m',
        posterUrl: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=900',
        price: 5.99,
        description:
            'An elite pilot must reboot global defense satellites before dawn starts a digital war.',
        streams: [low, medium, high],
      ),
    ];
  }
}
