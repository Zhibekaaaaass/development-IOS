import 'package:flutter/material.dart';

void main() {
  runApp(const BusinessApp());
}

class BusinessApp extends StatelessWidget {
  const BusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileCardScreen(),
    );
  }
}

class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  bool _isFollowing = false;
  int _followerCount = 1320;
  int _likesCount = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Center(
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.lime,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 16),

                Text('Tangyt Zhibeka'),
                Text('Student'),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_followerCount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Followers',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                          '$_likesCount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Likes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleFollow,
                      icon: Icon(
                        _isFollowing
                            ? Icons.check
                            : Icons.person_add,
                      ),
                      label: Text(
                        _isFollowing ? 'Following' : 'Follow',
                      ),
                    ),

                    OutlinedButton.icon(
                      onPressed: _like,
                      icon: Icon(Icons.thumb_up),
                      label: Text('Like'),
                    ),

                    OutlinedButton.icon(
                      onPressed: _dislike,
                      icon: Icon(Icons.thumb_down),
                      label: Text('Dislike'),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _reset,
                  child: Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;

      if (_isFollowing) {
        _followerCount++;
      } else {
        _followerCount--;
      }
    });
  }

  void _like() {
    setState(() {
      _likesCount++;
    });
  }

  void _dislike() {
    setState(() {
      _likesCount--;
    });
  }

  void _reset() {
    setState(() {
      _isFollowing = false;
      _followerCount = 1320;
      _likesCount = 120;
    });
  }
}

