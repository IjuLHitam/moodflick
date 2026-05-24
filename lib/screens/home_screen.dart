import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../utils/page_transition.dart';
import '../widgets/app_background.dart';
import '../widgets/movie_card.dart';
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

  final moods = const [
    {
      'name': 'Senang',
      'emoji': '😄',
      'subtitle': 'Film lucu & menghibur',
      'color1': Color(0xFFFFC857),
      'color2': Color(0xFFFF8C42),
    },
    {
      'name': 'Sedih',
      'emoji': '😔',
      'subtitle': 'Drama penuh emosi',
      'color1': Color(0xFF74B9FF),
      'color2': Color(0xFF6C5CE7),
    },
    {
      'name': 'Marah',
      'emoji': '😡',
      'subtitle': 'Aksi penuh adrenalin',
      'color1': Color(0xFFFF5E5E),
      'color2': Color(0xFFB80000),
    },
    {
      'name': 'Santai',
      'emoji': '😌',
      'subtitle': 'Dokumenter & musik',
      'color1': Color(0xFF6BCB77),
      'color2': Color(0xFF2D9C75),
    },
    {
      'name': 'Semangat',
      'emoji': '😆',
      'subtitle': 'Petualangan epik',
      'color1': Color(0xFFFFB347),
      'color2': Color(0xFFFF4D00),
    },
    {
      'name': 'Lelah',
      'emoji': '🥱',
      'subtitle': 'Ringan & menyenangkan',
      'color1': Color(0xFFB56CFF),
      'color2': Color(0xFF6C5CE7),
    },
  ];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  void loadMovies() {
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
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['username'] ??
        user?.email?.split('@').first ??
        'guest';

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(loadMovies);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 20 : 10,
                    isDesktop ? 12 : 14,
                    isDesktop ? 20 : 10,
                    24,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Selamat Sore,\n',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: '$name 👋',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.dark_mode_outlined),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      '✨ Gimana perasaanmu hari ini?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih mood dan temukan film yang tepat',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: moods.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 6 : 3,
                        mainAxisSpacing: isDesktop ? 12 : 10,
                        crossAxisSpacing: isDesktop ? 12 : 10,
                        childAspectRatio: isDesktop ? 1.15 : 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final mood = moods[index];

                        return InkWell(
                          onTap: () => openMood(mood['name'] as String),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  mood['color1'] as Color,
                                  mood['color2'] as Color,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (mood['color2'] as Color)
                                      .withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood['emoji'] as String,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 30 : 26,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  mood['name'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    mood['subtitle'] as String,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 10 : 8,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),
                    Divider(color: Colors.grey.withValues(alpha: 0.18)),
                    const SizedBox(height: 20),

                    const Text(
                      '↗ Featured',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 14),

                    FutureBuilder<List<Movie>>(
                      future: popular,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SkeletonBox(
                            width: double.infinity,
                            height: isDesktop ? 202 : 170,
                            radius: 22,
                          );
                        }

                        final movie = snapshot.data!.first;
                        final backdrop = movie.backdropPath.isEmpty
                            ? null
                            : '${AppConfig.backdropBaseUrl}${movie.backdropPath}';

                        return InkWell(
                          onTap: () => openDetail(movie),
                          borderRadius: BorderRadius.circular(22),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: SizedBox(
                              height: isDesktop ? 202 : 170,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: backdrop == null
                                        ? Container(color: Colors.grey)
                                        : CachedNetworkImage(
                                            imageUrl: backdrop,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.88),
                                            Colors.black.withValues(alpha: 0.28),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 14,
                                    bottom: 14,
                                    right: 14,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE92D35),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'FEATURED',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '⭐ ${movie.rating.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movie.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isDesktop ? 20 : 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          '${movie.releaseDate.isEmpty ? '-' : movie.releaseDate.split('-').first} • Klik untuk detail',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    movieSection('🔥 Popular', popular),
                    movieSection('📈 Trending Minggu Ini', trending),
                    movieSection('🎬 Sedang Tayang', nowPlaying),
                    movieSection('⭐ Rating Tertinggi', topRated),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget movieSection(String title, Future<List<Movie>> future) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Text(
              'Lihat Semua >',
              style: TextStyle(
                color: Color(0xFFE92D35),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: isDesktop ? 245 : 215,
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return const MovieCardSkeleton();
                  },
                );
              }

              final movies = snapshot.data!;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: movies[index],
                    onTap: () => openDetail(movies[index]),
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