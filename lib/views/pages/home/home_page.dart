import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scholarsync/controllers/club_service.dart';
import 'package:scholarsync/controllers/firebase_auth.dart';
import 'package:scholarsync/controllers/kuppi_service.dart';
import 'package:scholarsync/controllers/student_service.dart';
import 'package:scholarsync/model/student.dart';
import 'package:scholarsync/views/pages/home/kuppi_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:scholarsync/views/widgets/custom_searchbar.dart';
import '../../../model/club.dart';
import '../../../themes/palette.dart';
import 'widgets/clubs_row.dart';
import 'widgets/image_row.dart';
import '../../widgets/custom_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ClubService clubService = ClubService();
  final StudentService studentService = StudentService();
  final KuppisService kuppisService = KuppisService();
  final AuthService authService = AuthService();
  final User user = FirebaseAuth.instance.currentUser!;

  bool isLoading = false;
  late List<Map<String, dynamic>> suggestions = [];

  Future<void> fetchSuggestions() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> clubs =
        await clubService.getAllClubsInfo();

    setState(() {
      isLoading = false;
      suggestions = clubs;
    });
  }

  Future<Student?> _fetchStudent() async {
    final studentData = await studentService.fetchStudentData();
    return studentData;
  }

  @override
  void initState() {
    super.initState();
    clubService.listenForClubUpdates();
    fetchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: FutureBuilder(
                future: authService.checkIfUserIsClub(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == true) {
                      // User is a club owner
                      return FutureBuilder<Club?>(
                        future: clubService.getClubByEmail(user.email!),
                        builder: (context, clubSnapshot) {
                          if (clubSnapshot.connectionState ==
                              ConnectionState.done) {
                            final club = clubSnapshot.data;
                            return Text(
                              'Hello, ${club?.name ?? 'Club Owner'}',
                              style: Theme.of(context).textTheme.headlineLarge,
                            );
                          } else {
                            return Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.displaySmall,
                            );
                          }
                        },
                      );
                    } else {
                      // User is a student
                      return FutureBuilder<Student?>(
                        future: _fetchStudent(), // Fetch student data
                        builder: (context, studentSnapshot) {
                          if (studentSnapshot.connectionState ==
                              ConnectionState.done) {
                            final student = studentSnapshot.data;
                            return Text(
                              'Hello, ${student?.firstName ?? 'Student'}',
                              style: Theme.of(context).textTheme.headlineLarge,
                            );
                          } else {
                            return Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.displaySmall,
                            );
                          }
                        },
                      );
                    }
                  } else {
                    return Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.displaySmall,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  PhosphorIcons.fill.graduationCap,
                  color: CommonColors.secondaryGreenColor,
                  size: 18,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  'NSBM Green University',
                  style: TextStyle(
                    color: CommonColors.secondaryGreenColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              PhosphorIcons.bold.list,
              color: CommonColors.secondaryGreenColor,
              size: 28,
            ),
            tooltip: 'Menu',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                child: MyCustomSearchBar(
                  suggestions: suggestions,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              StreamBuilder<List<String>>(
                stream:
                    clubService.eventImageUrlsStream, // Listen to live updates
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    // Use the updated eventImageUrls
                    final eventImageUrls = snapshot.data ?? [];
                    return CustomCarousel(imageList: eventImageUrls);
                  } else {
                    // Show a loading indicator or placeholder while waiting for updates
                    return const CircularProgressIndicator(
                      color: CommonColors.secondaryGreenColor,
                    );
                  }
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kuppi Sessions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Route route = MaterialPageRoute(
                          builder: (context) => const KuppiPage());
                      Navigator.push(context, route);
                    },
                    child: Text(
                      'view all',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              ImageRow(
                containerSize: MediaQuery.of(context).size.width * 0.42,
                isCircle: false,
                imageStream: kuppisService.streamKuppiSessionImageURLs(),
              ),

              const SizedBox(height: 30),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clubs & Societies',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),
              ClubsRow(
                containerSize: MediaQuery.of(context).size.width * 0.25,
                imageStream: clubService.streamProfileImageURLs(),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
