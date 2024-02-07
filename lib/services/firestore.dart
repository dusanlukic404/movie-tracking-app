import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference movies =
      FirebaseFirestore.instance.collection('movies');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create
  Future<void> addMovie({
    required String name,
    required String urlLink,
    required String description,
    required String genre,
    required DateTime dateWatched,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // Store movie under the user's UID
      await movies.doc(userUid).collection('user_movies').add({
        'name': name,
        'urlLink': urlLink,
        'description': description,
        'genre': genre,
        'dateWatched': dateWatched,
      });
    } else {
      // Handle the case where the user is not logged in
      throw Exception('User not authenticated');
    }
  }

  // read
  Stream<QuerySnapshot> getMoviesStream() {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // Query movies for the specific user's UID
      final moviesStream = movies
          .doc(userUid)
          .collection('user_movies')
          .orderBy('dateWatched', descending: true)
          .snapshots();

      return moviesStream;
    } else {
      // If the user is not logged in, return an empty stream
      return Stream.empty();
    }
  }

  // update
  Future<void> updateMovie({
    required String movieId,
    required String name,
    required String urlLink,
    required String description,
    required String genre,
    required DateTime dateWatched,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // Update the movie with the given ID under the user's UID
      await movies.doc(userUid).collection('user_movies').doc(movieId).update({
        'name': name,
        'urlLink': urlLink,
        'description': description,
        'genre': genre,
        'dateWatched': dateWatched,
      });
    } else {
      // Handle the case where the user is not logged in
      throw Exception('User not authenticated');
    }
  }

  // edit
  Future<void> editMovie({
    required String id,
    required String name,
    required String urlLink,
    required String description,
    required String genre,
    required DateTime dateWatched,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // Update movie under the user's UID
      await movies.doc(userUid).collection('user_movies').doc(id).update({
        'name': name,
        'urlLink': urlLink,
        'description': description,
        'genre': genre,
        'dateWatched': dateWatched,
      }).catchError((error) => print("Failed to update movie: $error"));
    } else {
      // Handle the case where the user is not logged in
      throw Exception('User not authenticated');
    }
  }

  // read by id
  Future<DocumentSnapshot> getMovieById(String id) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // Get movie for the specific user's UID by ID
      final movie = await movies
          .doc(userUid)
          .collection('user_movies')
          .doc(id)
          .get()
          .catchError((error) => print("Failed to get movie: $error"));

      return movie;
    } else {
      // If the user is not logged in, return an empty document
      return FirebaseFirestore.instance.doc('empty/empty').get();
    }
  }

  // delete
  Future<void> deleteMovie(String movieId) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userUid = user.uid;

      // Delete the movie with the given ID under the user's UID
      await movies.doc(userUid).collection('user_movies').doc(movieId).delete();
    } else {
      // Handle the case where the user is not logged in
      throw Exception('User not authenticated');
    }
  }
}
