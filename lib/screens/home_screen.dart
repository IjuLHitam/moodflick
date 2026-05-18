import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../utils/page_transition.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton_loader.dart';
import 'detail_screen.dart';
import 'mood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final tmdb = TmdbService();

  late Future<List<Movie>> popular;
  late Future<List<Movie>> trending;
  late Future<List<Movie>> nowPlaying;
  late Future<List<Movie>> topRated;

  final moods = [
    {'name': 'Senang', 'emoji': '😊', 'color': Color(0xFFFFC857)},
    {'name': 'Sedih', 'emoji': '😢', 'color': Color(0xFF5DADEC)},
    {'name': 'Marah', 'emoji': '😡', 'color': Color(0xFFE94F37)},
    {'name': 'Santai', 'emoji': '😌', 'color': Color(0xFF62C370)},
    {'name': 'Semangat', 'emoji': '🔥', 'color': Color(0xFFFF8C42)},
    {'name': 'Lelah', 'emoji': '🥱', 'color': Color(0xFF9B5DE5)},
  ];

  @override
  void initState() {
    super.initState();
    popular = tmdb.popular();
    trending = tmdb.trendingWeek();
    nowPlaying = tmdb.nowPlaying();
    topRated = tmdb.topRated();
  }

void openDetail(Movie movie) {
  Navigator.push(
    context,
    createFadeSlideRoute(
      DetailScreen(movie: movie),
    ),
  );
}

void openMood(String mood) {
  Navigator.push(
    context,
    createFadeSlideRoute(
      MoodScreen(mood: mood),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              popular = tmdb.popular();
              trending = tmdb.trendingWeek();
              nowPlaying = tmdb.nowPlaying();
              topRated = tmdb.topRated();
            });
          },
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'Selamat datang di',
                style: TextStyle(color: Colors.grey),
              ),
              const Text(
                'MoodFlick 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gimana perasaanmu hari ini?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, i) {
                  final mood = moods[i];
                  return GlassCard(
  onTap: () => openMood(mood['name'] as String),
  padding: EdgeInsets.zero,
  color: (mood['color'] as Color).withValues(alpha: 0.85),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (mood['color'] as Color).withValues(alpha: 0.95),
          (mood['color'] as Color).withValues(alpha: 0.62),
        ],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mood['emoji'] as String,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          mood['name'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
);
                },
              ),
              const SizedBox(height: 24),
              movieSection('Popular', popular),
              movieSection('Trending Minggu Ini', trending),
              movieSection('Sedang Tayang', nowPlaying),
              movieSection('Rating Tertinggi', topRated),
            ],
          ),
        ),
      ),
    );
  }

  Widget movieSection(String title, Future<List<Movie>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 225,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
             if (!snapshot.hasData) {
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: 6,
    separatorBuilder: (_, index) => const SizedBox(width: 12),
    itemBuilder: (context, index) {
      return const MovieCardSkeleton();
    },
  );
}

              final movies = snapshot.data!;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  return MovieCard(
                    movie: movies[i],
                    onTap: () => openDetail(movies[i]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}