import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/firestore.dart';
import 'package:intl/intl.dart';

class MovieData {
  final String id;
  final String name;
  final String description;
  final String trailerUrl;
  final String genre;
  // final int rating;
  final DateTime dateWatched;

  MovieData({
    required this.id,
    required this.name,
    required this.description,
    required this.trailerUrl,
    required this.genre,
    // required this.rating,
    required this.dateWatched,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirestoreService firestoreService = FirestoreService();
  final movieNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final trailerUrlController = TextEditingController();
  final ratingController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  String searchQuery = "";
  bool sortByDateAscending = true;
  String selectedGenre = 'Action';
  String selectedGenreFilter = 'All';

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void toggleSortOrder() {
    setState(() {
      sortByDateAscending = !sortByDateAscending;
    });
  }

  void resetForm() {
    movieNameController.text = '';
    descriptionController.text = '';
    // ratingController.text = '';
    selectedGenre = 'Action';
    trailerUrlController.text = '';
    selectedDate = DateTime.now();
  }

  Future<void> openMovieBox(
      {bool isEditing = false, MovieData? initialData}) async {
    // Initialize controllers with initial data if editing
    if (isEditing && initialData != null) {
      movieNameController.text = initialData.name;
      descriptionController.text = initialData.description;
      trailerUrlController.text = initialData.trailerUrl;
      selectedGenre = initialData.genre;
      // ratingController.text = initialData.rating.toString();
      selectedDate = initialData.dateWatched;
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: movieNameController,
                    cursorColor: Colors.blue,
                    decoration: const InputDecoration(
                      labelText: 'Movie Name',
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    cursorColor: Colors.blue,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  TextField(
                    controller: trailerUrlController,
                    cursorColor: Colors.blue,
                    decoration: const InputDecoration(
                      labelText: 'Trailer URL',
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.normal),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    value: selectedGenre,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 20,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGenre = newValue!;
                      });
                    },
                    items: [
                      'Action',
                      'Comedy',
                      'Drama',
                      'Documentary',
                      'Sci-Fi'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  ListTile(
                    title: const Text('Date Watched'),
                    subtitle: Text(
                      "${selectedDate?.toLocal()}".split(' ')[0] ?? '',
                    ),
                    onTap: () async {
                      await openDatePicker();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isEditing) {
                        // Call the editMovie method from FirestoreService
                        firestoreService.editMovie(
                          id: initialData!.id,
                          name: movieNameController.text.trim(),
                          urlLink: trailerUrlController.text.trim(),
                          description: descriptionController.text.trim(),
                          genre: selectedGenre,
                          dateWatched: selectedDate ?? DateTime.now(),
                        );
                      } else {
                        // Call the addMovie method from FirestoreService
                        firestoreService.addMovie(
                          name: movieNameController.text.trim(),
                          urlLink: trailerUrlController.text.trim(),
                          description: descriptionController.text.trim(),
                          genre: selectedGenre,
                          dateWatched: selectedDate ?? DateTime.now(),
                        );
                      }

                      resetForm();
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      isEditing ? 'Edit Movie' : 'Add Movie',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Set primary color for the calendar
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> openEditMovieBox(String documentId) async {
    // Fetch movie data from Firestore using the documentId
    DocumentSnapshot document = await firestoreService.getMovieById(documentId);
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Set the initial data for the edit operation
    MovieData initialData = MovieData(
      id: document.id,
      name: data['name'],
      description: data['description'],
      trailerUrl: data['urlLink'],
      genre: data['genre'],
      dateWatched: (data['dateWatched'] as Timestamp).toDate(),
    );

    // Open the movie box for editing
    await openMovieBox(isEditing: true, initialData: initialData);
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        cursorColor: Colors.blue,
        decoration: InputDecoration(
          labelText: 'Search',
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          prefixIcon: const Icon(Icons.search),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieTracker'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.blue[600],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await openMovieBox();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          buildSearchBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    onPressed: toggleSortOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sort by Date',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(
                          sortByDateAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    value: selectedGenreFilter,
                    icon: const Icon(Icons.arrow_downward),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGenreFilter = newValue ?? 'All';
                      });
                    },
                    items: [
                      'All',
                      'Action',
                      'Comedy',
                      'Drama',
                      'Documentary',
                      'Sci-Fi'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getMoviesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List moviesList = snapshot.data!.docs;

                  if (moviesList.isEmpty) {
                    return const Center(
                      child: Text('No movies...'),
                    );
                  }

                  // Filter movies based on search query
                  List<MovieData> filteredMovies = moviesList
                      .map((document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return MovieData(
                          id: document.id,
                          name: data['name'],
                          description: data['description'],
                          trailerUrl: data['urlLink'],
                          genre: data['genre'],
                          dateWatched:
                              (data['dateWatched'] as Timestamp).toDate(),
                        );
                      })
                      .where((movie) =>
                          (selectedGenreFilter == 'All' ||
                              movie.genre == selectedGenreFilter) &&
                          (movie.name.toLowerCase().contains(searchQuery) ||
                              movie.description
                                  .toLowerCase()
                                  .contains(searchQuery)))
                      .toList();

                  if (filteredMovies.isEmpty && selectedGenreFilter == 'All') {
                    return Center(
                      child: Text('No movies for search: $searchQuery'),
                    );
                  }

                  if (selectedGenreFilter != 'All' && filteredMovies.isEmpty) {
                    return Center(
                        child:
                            Text('No movies for genre: $selectedGenreFilter'));
                  }

                  filteredMovies.sort((a, b) {
                    if (sortByDateAscending) {
                      return a.dateWatched.compareTo(b.dateWatched);
                    } else {
                      return b.dateWatched.compareTo(a.dateWatched);
                    }
                  });

                  return ListView.builder(
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      MovieData movie = filteredMovies[index];
                      DateTime dateWatched = movie.dateWatched;

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(movie.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${movie.description}'),
                              Text(
                                  'Date Watched: ${DateFormat('MMM dd, yyyy').format(dateWatched)}'),
                              Text('Genre: ${movie.genre}'),
                              InkWell(
                                onTap: () {
                                  // You can add navigation to open the trailer URL in a video player or web view
                                  // For simplicity, let's just print the URL for now
                                  print('Trailer URL: ${movie.trailerUrl}');
                                },
                                child: const Text(
                                  'Trailer URL',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Open the movie box for editing
                                  openEditMovieBox(movie.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Implement delete functionality here
                                  firestoreService.deleteMovie(movie.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Text('No movies...');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
