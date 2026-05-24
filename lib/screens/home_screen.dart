import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../utils/page_transition.dart';
import '../widgets/app_background.dart';
import '../widgets/mood_card.dart';
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

  final moods = const <Map<String, Object>>[
    {
      'key': 'senang',
      'title': 'Happy',
      'subtitle': 'Joy & Laughter',
      'icon': Icons.wb_sunny_outlined,
      'light1': Color(0xFFF6B73C),
      'light2': Color(0xFFE3942D),
      'dark1': Color(0xFF2D2417),
      'dark2': Color(0xFF0F1117),
    },
    {
      'key': 'sedih',
      'title': 'Sad',
      'subtitle': 'Melancholic',
      'icon': Icons.nightlight_round,
      'light1': Color(0xFF5B8CFF),
      'light2': Color(0xFF345EE8),
      'dark1': Color(0xFF0E2948),
      'dark2': Color(0xFF0F182B),
    },
    {
      'key': 'marah',
      'title': 'Angry',
      'subtitle': 'Intense & Raw',
      'icon': Icons.local_fire_department_outlined,
      'light1': Color(0xFFEA7A98),
      'light2': Color(0xFFD85B78),
      'dark1': Color(0xFF2A0E18),
      'dark2': Color(0xFF151017),
    },
    {
      'key': 'santai',
      'title': 'Relaxed',
      'subtitle': 'Calm & Easy',
      'icon': Icons.spa_outlined,
      'light1': Color(0xFF66D0D3),
      'light2': Color(0xFF34A8B8),
      'dark1': Color(0xFF0E2A2D),
      'dark2': Color(0xFF0A1A21),
    },
    {
      'key': 'semangat',
      'title': 'Motivated',
      'subtitle': 'Fired Up',
      'icon': Icons.bolt_outlined,
      'light1': Color(0xFFFFA85F),
      'light2': Color(0xFFEF7F3B),
      'dark1': Color(0xFF2A160D),
      'dark2': Color(0xFF141114),
    },
    {
      'key': 'lelah',
      'title': 'Tired',
      'subtitle': 'Need Rest',
      'icon': Icons.dark_mode_outlined,
      'light1': Color(0xFFA78BFA),
      'light2': Color(0xFF7C67D9),
      'dark1': Color(0xFF231A38),
      'dark2': Color(0xFF141423),
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

  Widget moodCard(
    Map<String, Object> mood, {
    bool tall = false,
  }) {
    return MoodCard(
      title: mood['title'] as String,
      subtitle: mood['subtitle'] as String,
      icon: mood['icon'] as IconData,
      lightColor1: mood['light1'] as Color,
      lightColor2: mood['light2'] as Color,
      darkColor1: mood['dark1'] as Color,
      darkColor2: mood['dark2'] as Color,
      compact: true,
      tall: tall,
      onTap: () => openMood(mood['key'] as String),
    );
  }

  Widget buildMoodSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useMosaic = constraints.maxWidth >= 720;

        if (!useMosaic) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 120,
            ),
            itemBuilder: (context, index) {
              return moodCard(moods[index]);
            },
          );
        }

        final sectionWidth =
            constraints.maxWidth > 620 ? 620.0 : constraints.maxWidth;

        const gap = 12.0;

        final leftW = (sectionWidth - gap) * 0.66;
        final rightW = sectionWidth - leftW - gap;

        const topH = 78.0;
        const midH = 70.0;
        const bottomH = 68.0;

        const sectionH = topH + gap + midH + gap + bottomH;

        final happy = moods[0];
        final sad = moods[1];
        final angry = moods[2];
        final relaxed = moods[3];
        final motivated = moods[4];
        final tired = moods[5];

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: sectionWidth,
            height: sectionH,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: leftW,
                  height: topH,
                  child: moodCard(happy),
                ),
                Positioned(
                  left: leftW + gap,
                  top: 0,
                  width: rightW,
                  height: topH + gap + midH,
                  child: moodCard(sad, tall: true),
                ),
                Positioned(
                  left: 0,
                  top: topH + gap,
                  width: (leftW - gap) / 2,
                  height: midH,
                  child: moodCard(angry),
                ),
                Positioned(
                  left: ((leftW - gap) / 2) + gap,
                  top: topH + gap,
                  width: (leftW - gap) / 2,
                  height: midH,
                  child: moodCard(relaxed),
                ),
                Positioned(
                  left: 0,
                  top: topH + gap + midH + gap,
                  width: leftW,
                  height: bottomH,
                  child: moodCard(motivated),
                ),
                Positioned(
                  left: leftW + gap,
                  top: topH + gap + midH + gap,
                  width: rightW,
                  height: bottomH,
                  child: moodCard(tired),
                ),
              ],
            ),
          ),
        );
      },
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
                                    ? Colors.white.withOpacity(0.08)
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
                                    ? Colors.white.withOpacity(0.08)
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

                    buildMoodSection(),

                    const SizedBox(height: 28),
                    Divider(color: Colors.grey.withOpacity(0.18)),
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
                                            Colors.black.withOpacity(0.88),
                                            Colors.black.withOpacity(0.28),
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