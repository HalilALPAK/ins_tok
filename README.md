# İnstok

Bu proje, Flask tabanlı bir sosyal medya uygulamasıdır. Kullanıcılar kayıt olabilir, giriş yapabilir, profil fotoğrafı yükleyebilir, gönderi paylaşabilir ve diğer kullanıcılarla etkileşime geçebilir.

## Özellikler

- Kullanıcı kaydı ve girişi (e-posta veya kullanıcı adı ile)
- Profil fotoğrafı yükleme
- Gönderi (fotoğraf/video) ekleme ve silme
- Gönderilere not ve hashtag ekleme
- Diğer kullanıcıları takip etme/bırakma
- Gönderi beğenme ve beğenmekten vazgeçme
- Tüm gönderileri listeleme

## Kurulum

1. **Gerekli paketleri yükleyin:**

   ```bash
   pip install flask flask-cors
   ```

   veya Anaconda kullanıyorsanız:

   ```bash
   conda install flask flask-cors
   ```

2. **Projeyi başlatın:**

   ```bash
   python app.py
   ```

3. **Sunucuya erişim:**
   - Uygulama varsayılan olarak `http://127.0.0.1:5000` adresinde çalışır.

## Kullanım

- **Kayıt:** `/register` endpoint'ine POST isteği ile (JSON: username, email, password) kayıt olabilirsiniz.
- **Giriş:** `/login` endpoint'ine POST isteği ile (JSON: username veya email, password) giriş yapabilirsiniz.
- **Profil Fotoğrafı Güncelleme:** `/update_profile_photo/<username>` endpoint'ine POST ile dosya yükleyebilirsiniz.
- **Gönderi Ekleme:** `/add_post/<username>` endpoint'ine POST ile gönderi ekleyebilirsiniz.
- **Tüm Gönderiler:** `/all_posts` endpoint'i ile tüm gönderileri çekebilirsiniz.

## Dosya Yapısı

- `app.py`: Sunucu kodları
- `users.json`: Kullanıcı ve gönderi verileri
- `uploads/`: Yüklenen medya dosyaları

## Önemli Notlar

- Uygulama geliştirme modunda çalışır, gerçek ortamda kullanmak için ek güvenlik önlemleri alınmalıdır.
- `users.json` dosyası UTF-8 formatında olmalıdır. Türkçe karakter desteği için dosya okuma/yazma işlemlerinde `encoding="utf-8"` kullanılır.
- API uç noktaları CORS desteklidir.

