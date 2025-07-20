
# 🧠 Gemini AI ile Kullanıcı İçerik Kategorilendirme ve Görselleştirme

Bu uygulama, kullanıcıların sosyal medya gönderilerini analiz ederek Gemini AI (Google) aracılığıyla hangi kategorilerle daha ilgili olduklarını yüzde (%) bazında tahmin eder ve bunu görselleştirir.

## 🚀 Özellikler

- Kullanıcıların beğendiği gönderiler ve izlediği videolar üzerinden analiz
- Gemini 1.5 Flash modeli ile metin tabanlı kategori tahmini
- Bar ve Pie grafiklerle kategori görselleştirmesi
- JSON formatında düzenli çıktı
- Streamlit tabanlı web arayüzü

## 📦 Gereksinimler

- Python 3.8+
- `streamlit`
- `pandas`
- `requests`

Kurulum:
```bash
pip install streamlit pandas requests
```

## ⚙️ API Yapısı

### 1. Kullanıcı Verisi API'si (`GET http://localhost:5000/users`)
Kullanıcıların:
- Kullanıcı adı
- Profil fotoğrafı
- Beğendiği gönderiler (not + hashtag)
- İzlediği videolar (not + hashtag + izlenme süresi + tekrar sayısı) gibi bilgileri sağlar.

### 2. Gemini API (`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent`)
Google'ın Gemini API'si üzerinden içerikler kategorilere ayrılır.

## 🔑 Ayarlar

`.env` veya doğrudan kod içinden API anahtarınızı girin:

```python
GEMINI_API_KEY = "API_ANAHTARINIZ"
```

## 📂 Kategoriler

Aşağıdaki kategorilerle eşleştirme yapılır:

```python
categories = [
  "matematik", "fizik", "kimya", "türkçe", "ingilizce",
  "tarih", "biyoloji", "uzay", "bitki", "hayvan",
  "doğa", "basketbol", "futbol", "voleybol", "tenis", "okçuluk",
  "python", "yazılım", "programlama", "teknoloji"
]
```

## 📊 Görselleştirme

- **Bar Chart**: Kategorilere göre yüzde dağılımı.
- **Pie Chart**: Yüzdelik orana göre pasta grafiği.

## 🧠 Analiz Kuralları

- Her içerik birden fazla kategoriye ait olabilir.
- Videoların izlenme etkisi, kategori puanına ağırlık katar.
- Eşleşmeyen içerikler `"önemsiz"` olarak etiketlenir.
- Yalnızca JSON çıktısı alınır.

## 🖥️ Uygulamayı Çalıştırma

```bash
streamlit run app.py
```

## 🐛 Hata Ayıklama

- Gemini'den gelen JSON yanıtı bozuksa, hata mesajı gösterilir.
- API hatalarında ilgili HTTP kodu ve hata mesajı döndürülür.

## 📸 Arayüz Örneği

- Kullanıcı seçimi dropdown
- Kullanıcı bilgileri ve profil fotoğrafı
- JSON çıktısı kod kutusu
- Bar Chart ve Pie Chart yan yana gösterimi

## 👨‍💻 Geliştirici Notları

- `clean_gemini_json`: Kod bloklarındaki ` ```json ` gibi işaretleri temizler.
- `build_input_text`: Kullanıcının like ve video izleme verilerini analiz için tek metne dönüştürür.
- `categorize_with_gemini`: Gemini API ile içerik kategorilendirmesi yapar.
