from flask import Flask, request, jsonify, send_from_directory
import json
import os
from flask_cors import CORS, cross_origin

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
USERS_FILE = 'users.json'
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def load_users():
    if not os.path.exists(USERS_FILE):
        return {}
    with open(USERS_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_users(users):
    with open(USERS_FILE, 'w', encoding='utf-8') as f:
        json.dump(users, f, ensure_ascii=False, indent=2)

@app.route('/register', methods=['POST'])
@cross_origin(origins="*")
def register():
    data = request.json
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    if not username or not password or not email:
        return jsonify({'success': False, 'message': 'Kullanıcı adı, e-posta ve şifre gerekli!'}), 400
    users = load_users()
    # Kullanıcı adı veya e-posta zaten var mı?
    for user in users.values():
        if not isinstance(user, dict):
            continue
        if user.get('email') == email:
            return jsonify({'success': False, 'message': 'Bu e-posta zaten kayıtlı!'}), 409
    if username in users:
        return jsonify({'success': False, 'message': 'Bu kullanıcı adı zaten var!'}), 409
    users[username] = {
        'email': email,
        'password': password,
        'profile_photo': '',
        'followers': 0,
        'following': 0,
        'posts': []
    }
    save_users(users)
    return jsonify({'success': True, 'message': 'Kayıt başarılı!'})

@app.route('/login', methods=['POST'])
@cross_origin(origins="*")
def login():
    data = request.json
    username_or_email = data.get('username')
    password = data.get('password')
    users = load_users()
    # Önce kullanıcı adı ile dene
    user = users.get(username_or_email)
    if isinstance(user, dict) and user.get('password') == password:
        return jsonify({'success': True, 'message': 'Giriş başarılı!', 'username': username_or_email})
    # Sonra e-posta ile dene
    for uname, user in users.items():
        if not isinstance(user, dict):
            continue
        if user.get('email') == username_or_email and user['password'] == password:
            return jsonify({'success': True, 'message': 'Giriş başarılı!', 'username': uname})
    return jsonify({'success': False, 'message': 'Kullanıcı adı/e-posta veya şifre yanlış!'}), 401

@app.route('/profile/<username>', methods=['GET'])
def get_profile(username):
    users = load_users()
    if username not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    user = users[username]
    profile = {
        'username': username,
        'profile_photo': user['profile_photo'],
        'followers': user['followers'],
        'following': user['following'],
        'post_count': len(user['posts']),
        'posts': user['posts']
    }
    return jsonify({'success': True, 'profile': profile})

@app.route('/update_profile_photo/<username>', methods=['POST'])
def update_profile_photo(username):
    print('update_profile_photo username:', username)
    if not username or username == 'None':
        print('Kullanıcı adı eksik!')
        return jsonify({'success': False, 'message': 'Kullanıcı adı eksik!'}), 400
    if 'photo' not in request.files:
        print('Dosya yok!')
        return jsonify({'success': False, 'message': 'Dosya yok!'}), 400
    file = request.files['photo']
    print('file.filename:', file.filename)
    if not file.filename:
        print('Dosya adı eksik!')
        return jsonify({'success': False, 'message': 'Dosya adı eksik!'}), 400
    filename = f'{username}_profile_{file.filename}'
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)
    users = load_users()
    if username not in users:
        print('Kullanıcı bulunamadı!')
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    users[username]['profile_photo'] = filename
    save_users(users)
    print('Profil fotoğrafı güncellendi:', filename)
    return jsonify({'success': True, 'message': 'Profil fotoğrafı güncellendi!', 'profile_photo': filename})

@app.route('/add_post/<username>', methods=['POST'])
def add_post(username):
    print('add_post username:', username)
    data = request.json
    print('add_post data:', data)
    media = data.get('media')
    note = data.get('note', '')
    hashtags = data.get('hashtags', '')
    # Dosya uzantısına göre tip belirle
    if media and (media.lower().endswith('.jpg') or media.lower().endswith('.jpeg') or media.lower().endswith('.png') or media.lower().endswith('.gif')):
        post_type = 'image'
    else:
        post_type = 'video'
    users = load_users()
    if username not in users:
        print('Kullanıcı bulunamadı!')
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    if not media:
        print('Media eksik!')
        return jsonify({'success': False, 'message': 'Media eksik!'}), 400
    post = {
        'media': media,
        'note': note,
        'hashtags': hashtags,
        'type': post_type
    }
    users[username]['posts'].append(post)
    save_users(users)
    print('Gönderi eklendi:', post)
    return jsonify({'success': True, 'message': 'Gönderi eklendi!'})

@app.route('/upload_post_media/<username>', methods=['POST'])
def upload_post_media(username):
    print('upload_post_media username:', username)
    if not username or username == 'None':
        print('Kullanıcı adı eksik!')
        return jsonify({'success': False, 'message': 'Kullanıcı adı eksik!'}), 400
    if 'media' not in request.files:
        print('Dosya yok!')
        return jsonify({'success': False, 'message': 'Dosya yok!'}), 400
    file = request.files['media']
    print('file.filename:', file.filename)
    if not file.filename:
        print('Dosya adı eksik!')
        return jsonify({'success': False, 'message': 'Dosya adı eksik!'}), 400
    filename = f'{username}_post_{file.filename}'
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)
    print('Dosya yüklendi:', filename)
    return jsonify({'success': True, 'media': filename})

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@app.route('/delete_post/<username>', methods=['POST'])
def delete_post(username):
    data = request.json
    media = data.get('media')
    note = data.get('note', '')
    hashtags = data.get('hashtags', '')
    users = load_users()
    if username not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    posts = users[username]['posts']
    new_posts = [p for p in posts if not (p['media'] == media and p['note'] == note and p['hashtags'] == hashtags)]
    users[username]['posts'] = new_posts
    save_users(users)
    return jsonify({'success': True, 'message': 'Gönderi silindi!'})

@app.route('/all_posts', methods=['GET'])
def all_posts():
    users = load_users()
    all_posts = []
    for username, user in users.items():
        # Bazı eski kullanıcılar string olarak kaydedilmiş olabilir, onları atla
        if not isinstance(user, dict):
            continue
        profile_photo = user.get('profile_photo', '')
        for post in user.get('posts', []):
            all_posts.append({
                'username': username,
                'profile_photo': profile_photo,
                'media': post.get('media', ''),
                'note': post.get('note', ''),
                'hashtags': post.get('hashtags', ''),
                'type': post.get('type', '')
            })
    # En yeni gönderiler en üstte olsun
    all_posts = all_posts[::-1]
    return jsonify({'success': True, 'posts': all_posts})

@app.route('/like_post', methods=['POST'])
@cross_origin(origins="*")
def like_post():
    data = request.json
    username = data.get('username')  # Beğenen kullanıcı
    post_owner = data.get('post_owner')  # Gönderi sahibi
    media = data.get('media')
    note = data.get('note', '')
    hashtags = data.get('hashtags', '')
    post_type = data.get('type', '')
    if not username or not post_owner or not media:
        return jsonify({'success': False, 'message': 'Eksik bilgi!'}), 400
    users = load_users()
    if username not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    if 'likes' not in users[username]:
        users[username]['likes'] = []
    # Aynı gönderi için kayıt varsa güncelle
    found = False
    for like in users[username]['likes']:
        if like['post_owner'] == post_owner and like['media'] == media:
            like['liked'] = True
            like['note'] = note
            like['hashtags'] = hashtags
            like['type'] = post_type
            found = True
            break
    if not found:
        users[username]['likes'].append({
            'post_owner': post_owner,
            'media': media,
            'note': note,
            'hashtags': hashtags,
            'type': post_type,
            'liked': True
        })
    save_users(users)
    return jsonify({'success': True, 'message': 'Beğeni kaydedildi!'})

@app.route('/dislike_post', methods=['POST'])
@cross_origin(origins="*")
def dislike_post():
    data = request.json
    username = data.get('username')  # Beğenmeyen kullanıcı
    post_owner = data.get('post_owner')  # Gönderi sahibi
    media = data.get('media')
    note = data.get('note', '')
    hashtags = data.get('hashtags', '')
    post_type = data.get('type', '')
    if not username or not post_owner or not media:
        return jsonify({'success': False, 'message': 'Eksik bilgi!'}), 400
    users = load_users()
    if username not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    if 'likes' not in users[username]:
        users[username]['likes'] = []
    # Aynı gönderi için kayıt varsa güncelle
    found = False
    for like in users[username]['likes']:
        if like['post_owner'] == post_owner and like['media'] == media:
            like['liked'] = False
            like['note'] = note
            like['hashtags'] = hashtags
            like['type'] = post_type
            found = True
            break
    if not found:
        users[username]['likes'].append({
            'post_owner': post_owner,
            'media': media,
            'note': note,
            'hashtags': hashtags,
            'type': post_type,
            'liked': False
        })
    save_users(users)
    return jsonify({'success': True, 'message': 'Beğenmeme kaydedildi!'})

@app.route('/follow_user', methods=['POST'])
@cross_origin(origins="*")
def follow_user():
    data = request.json
    follower = data.get('follower')  # Takip eden
    following = data.get('following')  # Takip edilen
    if not follower or not following or follower == following:
        return jsonify({'success': False, 'message': 'Eksik bilgi!'}), 400
    users = load_users()
    if follower not in users or following not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    # Takip edenin following listesine ekle
    if 'following_list' not in users[follower]:
        users[follower]['following_list'] = []
    if following not in users[follower]['following_list']:
        users[follower]['following_list'].append(following)
        users[follower]['following'] = len(users[follower]['following_list'])
    # Takip edilenin followers listesine ekle
    if 'followers_list' not in users[following]:
        users[following]['followers_list'] = []
    if follower not in users[following]['followers_list']:
        users[following]['followers_list'].append(follower)
        users[following]['followers'] = len(users[following]['followers_list'])
    save_users(users)
    return jsonify({'success': True, 'message': 'Takip edildi!'})

@app.route('/unfollow_user', methods=['POST'])
@cross_origin(origins="*")
def unfollow_user():
    data = request.json
    follower = data.get('follower')  # Takip eden
    following = data.get('following')  # Takip edilen
    if not follower or not following or follower == following:
        return jsonify({'success': False, 'message': 'Eksik bilgi!'}), 400
    users = load_users()
    if follower not in users or following not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    # Takip edenin following listesinden çıkar
    if 'following_list' in users[follower] and following in users[follower]['following_list']:
        users[follower]['following_list'].remove(following)
        users[follower]['following'] = len(users[follower]['following_list'])
    # Takip edilenin followers listesinden çıkar
    if 'followers_list' in users[following] and follower in users[following]['followers_list']:
        users[following]['followers_list'].remove(follower)
        users[following]['followers'] = len(users[following]['followers_list'])
    save_users(users)
    return jsonify({'success': True, 'message': 'Takipten çıkıldı!'})

@app.route('/watch_video', methods=['POST'])
@cross_origin(origins="*")
def watch_video():
    data = request.json
    username = data.get('username')  # İzleyen kullanıcı
    post_owner = data.get('post_owner')  # Video sahibi
    media = data.get('media')
    watched_seconds = data.get('watched_seconds', 0)
    watch_count = data.get('watch_count', 1)
    note = data.get('note', '')
    hashtags = data.get('hashtags', '')
    if not username or not post_owner or not media:
        return jsonify({'success': False, 'message': 'Eksik bilgi!'}), 400
    users = load_users()
    if username not in users:
        return jsonify({'success': False, 'message': 'Kullanıcı bulunamadı!'}), 404
    if 'video_watches' not in users[username]:
        users[username]['video_watches'] = []
    found = False
    for vw in users[username]['video_watches']:
        if vw['post_owner'] == post_owner and vw['media'] == media:
            vw['watched_seconds'] += watched_seconds
            vw['watch_count'] += watch_count
            vw['note'] = note
            vw['hashtags'] = hashtags
            found = True
            break
    if not found:
        users[username]['video_watches'].append({
            'post_owner': post_owner,
            'media': media,
            'watched_seconds': watched_seconds,
            'watch_count': watch_count,
            'note': note,
            'hashtags': hashtags
        })
    save_users(users)
    return jsonify({'success': True, 'message': 'Video izlenme kaydedildi!'})

@app.route('/users', methods=['GET'])
@cross_origin(origins="*")
def get_users():
    users = load_users()
    public_users = []
    for username, user in users.items():
        if not isinstance(user, dict):
            continue
        public_users.append({
            'username': username,
            'profile_photo': user.get('profile_photo', ''),
            'followers': user.get('followers', 0),
            'following': user.get('following', 0),
            'likes': user.get('likes', []),
            'video_watches': user.get('video_watches', []),
        })
    return jsonify({'success': True, 'users': public_users})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True) 