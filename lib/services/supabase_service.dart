import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movie.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  User? get currentUser => supabase.auth.currentUser;

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );

    final user = response.user;

    if (user != null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'username': username,
        'email': email,
      });
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    return await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  Future<void> updateUsername(String username) async {
    final user = currentUser;
    if (user == null) return;

    await supabase
        .from('profiles')
        .update({'username': username})
        .eq('id', user.id);
  }

  Future<void> addWatchlist(Movie movie, {String? mood}) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Login dulu untuk menyimpan watchlist');
    }

    await supabase.from('watchlists').upsert(
          movie.toSupabase(userId: user.id, mood: mood),
          onConflict: 'user_id,movie_id',
        );
  }

  Future<void> addHistory(Movie movie, {String? mood}) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Login dulu untuk menyimpan riwayat');
    }

    await supabase.from('histories').upsert(
          movie.toSupabase(userId: user.id, mood: mood),
          onConflict: 'user_id,movie_id',
        );
  }

  Future<List<Map<String, dynamic>>> getWatchlists() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('watchlists')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getHistories() async {
    final user = currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('histories')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> removeWatchlist(int movieId) async {
    final user = currentUser;
    if (user == null) return;

    await supabase
        .from('watchlists')
        .delete()
        .eq('user_id', user.id)
        .eq('movie_id', movieId);
  }
}