import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../utils/page_transition.dart';
import '../widgets/app_background.dart';
import '../widgets/skeleton_loader.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final tmdb = TmdbService();
  final searchC = TextEditingController();

  List<Movie> movies = [];
  bool loading = false;

  String filter = 'popular';
  String sort = 'default';

  @override
  void initState() {
    super.initState();
    loadByFilter();
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  Future<void> loadByFilter() async {
    setState(() => loading = true);

    try {
      if (filter == 'popular') {
        movies = await tmdb.popular();
      } else if (filter == 'trending') {
        movies = await tmdb.trendingWeek();
      } else if (filter == 'top') {
        movies = await tmdb.topRated();
      } else if (filter == 'now') {
        movies = await tmdb.nowPlaying();
      } else if (filter == 'upcoming') {
        movies = await tmdb.upcoming();
      }
    } catch (e) {
      showMsg('Gagal mengambil film');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> searchMovie() async {
    final keyword = searchC.text.trim();

    if (keyword.isEmpty) {
      await loadByFilter();
      return;
    }

    setState(() => loading = true);

    try {
      movies = await tmdb.search(keyword);
    } catch (e) {
      showMsg('Gagal mencari film');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  List<Movie> sortedMovies() {
    final list = [...movies];

    if (sort == 'rating_high') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sort == 'rating_low') {
      list.sort((a, b) => a.rating.compareTo(b.rating));
    }

    return list;
  }

  void openDetail(Movie movie) {
    Navigator.push(
      context,
      createFadeSlideRoute(
        DetailScreen(movie: movie),
      ),
    );
  }

  void showMsg(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = sortedMovies();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              final horizontalPadding = isDesktop ? 26.0 : 10.0;
              final totalHorizontalPadding = horizontalPadding * 2;

              final crossAxisCount = isDesktop ? 8 : 3;
              final crossAxisSpacing = isDesktop ? 12.0 : 10.0;
              final mainAxisSpacing = isDesktop ? 20.0 : 18.0;

              final availableWidth =
                  constraints.maxWidth - totalHorizontalPadding;

              final itemWidth = (availableWidth -
                      ((crossAxisCount - 1) * crossAxisSpacing)) /
                  crossAxisCount;

              final posterHeight = itemWidth * 1.5;

              final itemHeight = posterHeight + 46;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isDesktop ? 14 : 14,
                  horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cari Film',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: searchC,
                      onSubmitted: (_) => searchMovie(),
                      decoration: InputDecoration(
                        hintText: 'Judul film, aktor, genre...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          onPressed: searchMovie,
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE92D35),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          filterButton('🔥 Popular', 'popular'),
                          filterButton('📈 Trending', 'trending'),
                          filterButton('⭐ Top Rated', 'top'),
                          filterButton('🎬 Tayang', 'now'),
                          filterButton('🗓️ Upcoming', 'upcoming'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text(
                            'Urutkan:',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          sortButton('Default', 'default'),
                          sortButton('⭐ Tertinggi', 'rating_high'),
                          sortButton('⭐ Terendah', 'rating_low'),
                          const SizedBox(width: 10),
                          Text(
                            '${data.length} film',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: loading
                          ? const MovieGridSkeleton()
                          : data.isEmpty
                              ? const Center(
                                  child: Text('Film tidak ditemukan'),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 90),
                                  itemCount: data.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisExtent: itemHeight,
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: mainAxisSpacing,
                                  ),
                                  itemBuilder: (context, index) {
                                    return SearchMovieTile(
                                      movie: data[index],
                                      onTap: () => openDetail(data[index]),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget filterButton(String label, String value) {
    final active = filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        showCheckmark: false,
        selectedColor: const Color(0xFFE92D35),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : null,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: active
                ? const Color(0xFFE92D35)
                : Colors.grey.withValues(alpha: 0.22),
          ),
        ),
        onSelected: (_) {
          setState(() {
            filter = value;
            searchC.clear();
          });

          loadByFilter();
        },
      ),
    );
  }

  Widget sortButton(String label, String value) {
    final active = sort == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        showCheckmark: false,
        selectedColor: const Color(0xFFE92D35),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : null,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: active
                ? const Color(0xFFE92D35)
                : Colors.grey.withValues(alpha: 0.18),
          ),
        ),
        onSelected: (_) {
          setState(() => sort = value);
        },
      ),
    );
  }
}

class SearchMovieTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const SearchMovieTile({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath.isEmpty
        ? null
        : '${AppConfig.imageBaseUrl}${movie.posterPath}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: posterUrl == null
                        ? Container(
                            color: Colors.grey.withValues(alpha: 0.25),
                            child: const Icon(Icons.movie),
                          )
                        : CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                          ),
                  ),

                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.30),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⭐ ${movie.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.48),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            movie.releaseDate.isEmpty
                ? '-'
                : movie.releaseDate.split('-').first,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}