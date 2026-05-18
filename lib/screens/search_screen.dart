import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../utils/page_transition.dart';
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

  @override
  void initState() {
    super.initState();
    loadByFilter();
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
      } else {
        movies = await tmdb.nowPlaying();
      }
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> searchMovie() async {
    if (searchC.text.trim().isEmpty) {
      await loadByFilter();
      return;
    }

    setState(() => loading = true);

    try {
      movies = await tmdb.search(searchC.text.trim());
    } finally {
      setState(() => loading = false);
    }
  }

  void openDetail(Movie movie) {
  Navigator.push(
    context,
    createFadeSlideRoute(
      DetailScreen(movie: movie),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Film'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchC,
              onSubmitted: (_) => searchMovie(),
              decoration: InputDecoration(
                hintText: 'Judul film, aktor, genre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: searchMovie,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                filterChip('Popular', 'popular'),
                filterChip('Trending', 'trending'),
                filterChip('Top Rated', 'top'),
                filterChip('New Release', 'new'),
              ],
            ),
          ),
          Expanded(
  child: loading
      ? const MovieGridSkeleton()
      : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                    ),
                    itemBuilder: (context, i) {
                      return MovieCard(
                        movie: movies[i],
                        onTap: () => openDetail(movies[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String label, String value) {
    final active = filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        selectedColor: const Color(0xFFE92D35),
        labelStyle: TextStyle(
          color: active ? Colors.white : null,
        ),
        onSelected: (_) {
          setState(() => filter = value);
          loadByFilter();
        },
      ),
    );
  }
}