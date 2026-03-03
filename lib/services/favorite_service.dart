import 'package:flutter/foundation.dart';

class FavoriteService {
  FavoriteService._();

  static final ValueNotifier<Set<String>> favoriteIds =
      ValueNotifier<Set<String>>(<String>{});

  static bool isFavorite(String id) {
    return favoriteIds.value.contains(id);
  }

  static void add(String id) {
    if (favoriteIds.value.contains(id)) return;
    favoriteIds.value = <String>{...favoriteIds.value, id};
  }

  static void remove(String id) {
    if (!favoriteIds.value.contains(id)) return;
    final next = <String>{...favoriteIds.value};
    next.remove(id);
    favoriteIds.value = next;
  }

  static bool toggle(String id) {
    final next = <String>{...favoriteIds.value};
    final wasFavorite = next.contains(id);
    if (wasFavorite) {
      next.remove(id);
    } else {
      next.add(id);
    }
    favoriteIds.value = next;
    return !wasFavorite;
  }
}
