import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(InstokApp());
}

class InstokApp extends StatelessWidget {
  const InstokApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instok',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static String currentUsername = '';
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String username = '';
  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final url =
          isLogin
              ? Uri.parse('http://localhost:5000/login')
              : Uri.parse('http://localhost:5000/register');
      final body =
          isLogin
              ? {'username': username, 'password': password}
              : {'username': username, 'email': email, 'password': password};
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Kullanıcı adını kaydet
        if (isLogin) {
          currentUsername = data['username'] ?? username;
        } else {
          currentUsername = username;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Bir hata oluştu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('lib/assets/images/gorsel.png', fit: BoxFit.cover),
          Center(
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 350),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Instok',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!isLogin)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Kullanıcı Adı',
                                ),
                                onChanged: (val) => username = val,
                                validator:
                                    (val) =>
                                        val == null || val.isEmpty
                                            ? 'Kullanıcı adı girin'
                                            : null,
                              ),
                            if (!isLogin)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'E-posta',
                                ),
                                onChanged: (val) => email = val,
                                validator:
                                    (val) =>
                                        val == null || !val.contains('@')
                                            ? 'Geçerli e-posta girin'
                                            : null,
                              ),
                            if (isLogin)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Kullanıcı Adı veya E-posta',
                                ),
                                onChanged: (val) => username = val,
                                validator:
                                    (val) =>
                                        val == null || val.isEmpty
                                            ? 'Kullanıcı adı veya e-posta girin'
                                            : null,
                              ),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Şifre'),
                              obscureText: true,
                              onChanged: (val) => password = val,
                              validator:
                                  (val) =>
                                      val == null || val.length < 6
                                          ? 'En az 6 karakter'
                                          : null,
                            ),
                            SizedBox(height: 24),
                            isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(
                                    isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                            TextButton(
                              onPressed:
                                  () => setState(() => isLogin = !isLogin),
                              child: Text(
                                isLogin
                                    ? 'Hesabın yok mu? Kayıt ol'
                                    : 'Zaten hesabın var mı? Giriş yap',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [FeedScreen(), AddPostScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Akış'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Paylaş'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  Map<String, bool?> userLikes = {}; // key: postKey, value: true/false/null
  Set<String> followingSet = {}; // Takip edilen kullanıcı adları

  @override
  void initState() {
    super.initState();
    _fetchAllPosts();
    _fetchUserLikes();
    _fetchFollowing();
  }

  Future<void> _fetchAllPosts() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('http://localhost:5000/all_posts');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          posts = List<Map<String, dynamic>>.from(data['posts'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Akış yüklenemedi!')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Akış yüklenemedi: $e')));
    }
  }

  Future<void> _fetchUserLikes() async {
    final currentUsername = _AuthScreenState.currentUsername;
    if (currentUsername.isEmpty) return;
    try {
      final url = Uri.parse('http://localhost:5000/profile/$currentUsername');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final likes = List<Map<String, dynamic>>.from(
          data['profile']['likes'] ?? [],
        );
        Map<String, bool?> likesMap = {};
        for (final like in likes) {
          final key = _postKey(like['post_owner'], like['media']);
          likesMap[key] = like['liked'];
        }
        setState(() {
          userLikes = likesMap;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchFollowing() async {
    final currentUsername = _AuthScreenState.currentUsername;
    if (currentUsername.isEmpty) return;
    try {
      final url = Uri.parse('http://localhost:5000/profile/$currentUsername');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final followingList = List<String>.from(
          data['profile']['following_list'] ?? [],
        );
        setState(() {
          followingSet = followingList.toSet();
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleFollow(String targetUsername) async {
    final currentUsername = _AuthScreenState.currentUsername;
    if (currentUsername.isEmpty || currentUsername == targetUsername) return;
    final isFollowing = followingSet.contains(targetUsername);
    final url = Uri.parse(
      'http://localhost:5000/' +
          (isFollowing ? 'unfollow_user' : 'follow_user'),
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'follower': currentUsername,
        'following': targetUsername,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        if (isFollowing) {
          followingSet.remove(targetUsername);
        } else {
          followingSet.add(targetUsername);
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Takip işlemi başarısız!')));
    }
  }

  String _postKey(String owner, String media) => owner + '||' + media;

  Future<void> _likeOrDislike(Map<String, dynamic> post, bool liked) async {
    final currentUsername = _AuthScreenState.currentUsername;
    final postOwner = post['username'] ?? '';
    final media = post['media'] ?? '';
    final note = post['note'] ?? '';
    final hashtags = post['hashtags'] ?? '';
    final type = post['type'] ?? '';
    final url = Uri.parse(
      'http://localhost:5000/' + (liked ? 'like_post' : 'dislike_post'),
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': currentUsername,
        'post_owner': postOwner,
        'media': media,
        'note': note,
        'hashtags': hashtags,
        'type': type,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        userLikes[_postKey(postOwner, media)] = liked;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('İşlem başarısız!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (posts.isEmpty) {
      return Center(child: Text('Henüz hiç gönderi yok.'));
    }
    final currentUsername = _AuthScreenState.currentUsername;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final profilePhoto = post['profile_photo'] ?? '';
        final username = post['username'] ?? '';
        final media = post['media'] ?? '';
        final note = post['note'] ?? '';
        final hashtags = post['hashtags'] ?? '';
        final type = post['type'] ?? 'image';
        final postKey = _postKey(username, media);
        final liked = userLikes[postKey];
        final isFollowing = followingSet.contains(username);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          profilePhoto.isNotEmpty
                              ? NetworkImage(
                                profilePhoto.startsWith('http')
                                    ? profilePhoto
                                    : 'http://localhost:5000/uploads/' +
                                        profilePhoto,
                              )
                              : AssetImage('lib/assets/images/gorsel.png')
                                  as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (currentUsername != username)
                      ElevatedButton(
                        onPressed: () => _toggleFollow(username),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFollowing ? Colors.grey[300] : Colors.purple,
                          foregroundColor:
                              isFollowing ? Colors.black87 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isFollowing ? 'Takipten Çık' : 'Takip Et',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      type == 'image'
                          ? Image.network(
                            media.startsWith('http')
                                ? media
                                : 'http://localhost:5000/uploads/' + media,
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            width: double.infinity,
                            height: 260,
                            color: Colors.black12,
                            child: Center(
                              child: Icon(
                                Icons.videocam,
                                size: 64,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                ),
                SizedBox(height: 10),
                if (note.isNotEmpty) Text(note, style: TextStyle(fontSize: 15)),
                if (hashtags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      hashtags,
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: liked == true ? Colors.green : Colors.grey,
                      ),
                      onPressed:
                          currentUsername == username
                              ? null
                              : () => _likeOrDislike(post, true),
                      tooltip: 'Beğen',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        color: liked == false ? Colors.red : Colors.grey,
                      ),
                      onPressed:
                          currentUsername == username
                              ? null
                              : () => _likeOrDislike(post, false),
                      tooltip: 'Beğenme',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  String? selectedFileName;
  String? selectedFilePath;
  final TextEditingController noteController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();
  Uint8List? resultWebBytes;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'],
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFilePath = result.files.single.path;
        resultWebBytes = result.files.single.bytes;
      });
    }
  }

  void _onDropFile(dynamic details) {
    // Sadece UI için, gerçek sürükle-bırak desteği web/desktop için özel paketlerle yapılabilir.
    // Burada sadece simülasyon yapılacak.
    setState(() {
      selectedFileName = 'suruklenen_dosya.mp4';
      selectedFilePath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sürükle-bırak ile dosya eklendi (sadece UI)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _sharePost() async {
    if (selectedFilePath == null && (!kIsWeb || selectedFileName == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lütfen bir dosya seçin.')));
      return;
    }
    final currentUsername = _AuthScreenState.currentUsername;
    try {
      // 1. Dosyayı backend'e yükle
      var uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/upload_post_media/$currentUsername'),
      );
      if (kIsWeb && selectedFileName != null && resultWebBytes != null) {
        uploadRequest.files.add(
          http.MultipartFile.fromBytes(
            'media',
            resultWebBytes!,
            filename: selectedFileName,
          ),
        );
      } else if (selectedFilePath != null) {
        uploadRequest.files.add(
          await http.MultipartFile.fromPath(
            'media',
            selectedFilePath!,
            filename: selectedFileName,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dosya seçilemedi!')));
        return;
      }
      final uploadResponse = await uploadRequest.send();
      if (uploadResponse.statusCode != 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dosya yüklenemedi!')));
        return;
      }
      final uploadRespStr = await uploadResponse.stream.bytesToString();
      final uploadData = jsonDecode(uploadRespStr);
      final mediaFileName = uploadData['media'];
      // 2. Gönderi kaydını ekle
      final postResponse = await http.post(
        Uri.parse('http://localhost:5000/add_post/$currentUsername'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'media': mediaFileName,
          'note': noteController.text,
          'hashtags': hashtagController.text,
        }),
      );
      final postData = jsonDecode(postResponse.body);
      if (postResponse.statusCode == 200 && postData['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Paylaşım gönderildi!')));
        setState(() {
          selectedFileName = null;
          selectedFilePath = null;
          noteController.clear();
          hashtagController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(postData['message'] ?? 'Gönderi eklenemedi!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            GestureDetector(
              onTap: _pickFile,
              child: DragTarget(
                onAccept: (data) => _onDropFile(data),
                builder: (context, candidateData, rejectedData) {
                  return DottedBorder(
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      alignment: Alignment.center,
                      child:
                          selectedFileName == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    size: 48,
                                    color: Colors.purple,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Görsel / Video sürükle-bırak veya tıkla ve seç',
                                  ),
                                ],
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (selectedFilePath != null &&
                                      (selectedFilePath!.endsWith('.jpg') ||
                                          selectedFilePath!.endsWith('.jpeg') ||
                                          selectedFilePath!.endsWith('.png') ||
                                          selectedFilePath!.endsWith('.gif')))
                                    Image.file(
                                      File(selectedFilePath!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  else if (selectedFilePath != null &&
                                      (selectedFilePath!.endsWith('.mp4') ||
                                          selectedFilePath!.endsWith('.mov') ||
                                          selectedFilePath!.endsWith('.avi')))
                                    Icon(
                                      Icons.videocam,
                                      size: 48,
                                      color: Colors.purple,
                                    )
                                  else
                                    Icon(
                                      Icons.insert_drive_file,
                                      size: 40,
                                      color: Colors.purple,
                                    ),
                                  SizedBox(height: 8),
                                  Text(selectedFileName!),
                                ],
                              ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Not ekle',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            TextField(
              controller: hashtagController,
              decoration: InputDecoration(
                labelText: 'Hashtag ekle (örn: #tatil #yaz)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _sharePost,
              icon: Icon(Icons.send),
              label: Text('Paylaş'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String profileImage = '';
  int postCount = 0;
  int followers = 0;
  int following = 0;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool showEditFields = false;
  bool isLoading = true;
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final currentUsername = _AuthScreenState.currentUsername;
      final url = Uri.parse('http://localhost:5000/profile/$currentUsername');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final profile = data['profile'];
        setState(() {
          username = profile['username'] ?? '';
          profileImage = profile['profile_photo'] ?? '';
          postCount = profile['post_count'] ?? 0;
          followers = profile['followers'] ?? 0;
          following = profile['following'] ?? 0;
          _usernameController.text = username;
          posts = List<Map<String, dynamic>>.from(profile['posts'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Profil bilgisi alınamadı'),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profil bilgisi alınamadı: $e')));
    }
  }

  Future<void> _pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      final fileName = result.files.single.name;
      final currentUsername = _AuthScreenState.currentUsername;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'http://localhost:5000/update_profile_photo/$currentUsername',
        ),
      );
      if (kIsWeb && result.files.single.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            result.files.single.bytes!,
            filename: fileName,
          ),
        );
      } else if (result.files.single.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            result.files.single.path!,
            filename: fileName,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dosya seçilemedi!')));
        return;
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        setState(() {
          profileImage =
              'http://localhost:5000/uploads/' + data['profile_photo'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil fotoğrafı güncellendi!')),
        );
        _fetchProfile(); // Profil bilgisini güncelle
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil fotoğrafı yüklenemedi!')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    // Bu kısım ileride HTTP istekleriyle backend'e gönderilecek
    // Şimdilik sadece UI gösterimi için
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profil güncelleniyor...')));
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      username = _usernameController.text;
      showEditFields = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profil güncellendi')));
  }

  Future<void> _removePost(int index) async {
    final currentUsername = _AuthScreenState.currentUsername;
    final post = posts[index];
    final response = await http.post(
      Uri.parse('http://localhost:5000/delete_post/$currentUsername'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'media': post['media'],
        'note': post['note'],
        'hashtags': post['hashtags'],
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      setState(() {
        posts.removeAt(index);
        postCount = posts.length;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gönderi silindi!')));
      _fetchProfile(); // Profil bilgisini güncelle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Gönderi silinemedi!')),
      );
    }
  }

  Future<void> _signOut() async {
    // Bu kısım ileride HTTP istekleriyle backend'e gönderilecek
    // Şimdilik sadece UI gösterimi için
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Çıkış yapılıyor...')));
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 8,
          color: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundImage:
                              profileImage.isNotEmpty
                                  ? NetworkImage(
                                    profileImage.startsWith('http')
                                        ? profileImage
                                        : 'http://localhost:5000/uploads/' +
                                            profileImage,
                                  )
                                  : AssetImage('lib/assets/images/gorsel.png')
                                      as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: EdgeInsets.all(4),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () async {
                                print(
                                  'Profil fotoğrafı güncelleme ikonuna tıklandı',
                                );
                                try {
                                  await _pickProfileImage();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Dosya seçici açılamadı: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Profil fotoğrafını değiştir',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ProfileStat(
                              title: 'Gönderi',
                              value: postCount.toString(),
                            ),
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: _ProfileStat(
                              title: 'Takipçi',
                              value: followers.toString(),
                            ),
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: _ProfileStat(
                              title: 'Takip',
                              value: following.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      () => setState(() => showEditFields = !showEditFields),
                  child: Text(
                    showEditFields ? 'Düzenlemeyi Kapat' : 'Profili Düzenle',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (showEditFields) ...[
                  SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Yeni Şifre (isteğe bağlı)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _signOut,
                  child: Text('Çıkış Yap'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gönderiler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              post['type'] == 'image'
                                  ? Image.network(
                                    (post['media'] ?? '').startsWith('http')
                                        ? post['media']
                                        : 'http://localhost:5000/uploads/' +
                                            (post['media'] ?? ''),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    color: Colors.black12,
                                    child: Center(
                                      child: Icon(
                                        Icons.videocam,
                                        size: 48,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removePost(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileStat({Key? key, required this.title, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}
