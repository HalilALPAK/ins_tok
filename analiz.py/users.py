import requests
import streamlit as st
import json
import pandas as pd
import re

# Sabitler
API_URL = "http://localhost:5000/users"
GEMINI_API_KEY = ""
GEMINI_MODEL = "gemini-1.5-flash-latest"
GEMINI_ENDPOINT = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"

categories = [
    "matematik", "fizik", "kimya", "türkçe", "ingilizce",
    "tarih", "biyoloji", "uzay", "bitki", "hayvan",
    "doğa", "basketbol", "futbol", "voleybol", "tenis", "okçuluk",
    "python", "yazılım", "programlama", "teknoloji"
]

def clean_gemini_json(raw_text):
    cleaned = re.sub(r"```json|```", "", raw_text).strip()
    return cleaned

def build_input_text(user):
    contents = []
    for like in user.get("likes", []):
        note = like.get("note", "")
        hashtags = ", ".join(like.get("hashtags", [])) if isinstance(like.get("hashtags"), list) else like.get("hashtags", "")
        contents.append(f"Gönderi Notu: {note} | Hashtagler: {hashtags}")

    for vw in user.get("video_watches", []):
        note = vw.get("note", "")
        hashtags = ", ".join(vw.get("hashtags", [])) if isinstance(vw.get("hashtags"), list) else vw.get("hashtags", "")
        watched = vw.get("watched_seconds", 0)
        repeat = vw.get("watch_count", 0)

        multiplier = max(1, repeat) + (watched / 60)
        entry = f"Video Notu: {note} | Hashtagler: {hashtags} | İzlenme Etkisi: {multiplier:.2f} kat"
        contents.append(entry)

    return "\n".join(contents)

def categorize_with_gemini(prompt):
    try:
        headers = {"Content-Type": "application/json"}
        body = {
            "contents": [
                {
                    "role": "user",
                    "parts": [{
                        "text": f"""
Aşağıdaki içerikleri analiz et. Şu kategorilere oranla yüzde (%) dağılımını JSON formatında ver:

Kategoriler: {categories}

Kurallar:
- Her içerik birden fazla kategoriye ait olabilir.
- Bir içeriğin 'izlenme etkisi' varsa, ilgili kategori yüzdesini artır.
- Kategoriler dışında kalan içerikler "önemsiz" olarak değerlendirilmelidir.
- Sonucu sadece JSON formatında döndür, örnek:
{{
  "fizik": "30%",
  "teknoloji": "25%",
  "önemsiz": "10%"
}}

Veriler:
{prompt}
"""
                    }]
                }
            ]
        }

        res = requests.post(GEMINI_ENDPOINT, json=body, headers=headers)
        if res.status_code == 200:
            data = res.json()
            reply = data["candidates"][0]["content"]["parts"][0]["text"]
            return reply
        else:
            return f"Hata: {res.status_code} - {res.text}"
    except Exception as e:
        return f"Hata oluştu: {str(e)}"

def fetch_users():
    try:
        response = requests.get(API_URL)
        data = response.json()
        if data.get("success"):
            return data["users"]
        else:
            st.error("API'den veri alınamadı!")
            return []
    except Exception as e:
        st.error(f"Hata: {e}")
        return []

st.title("Gemini ile Kategori Analizi ve Görselleştirme")

users = fetch_users()

if not users:
    st.warning("Hiç kullanıcı bulunamadı.")
else:
    usernames = [u["username"] for u in users]
    selected = st.selectbox("Bir kullanıcı seç:", usernames)
    user = next((u for u in users if u["username"] == selected), None)

    if user:
        st.markdown(f"### 👤 {user['username']} Detayları")
        st.image(f"http://localhost:5000/uploads/{user['profile_photo']}", width=100)

        st.markdown("### 📊 Kategori Yüzdeleri (Gemini AI)")

        input_text = build_input_text(user)

        with st.spinner("Gemini kategorize ediyor..."):
            result = categorize_with_gemini(input_text)

        cleaned_result = clean_gemini_json(result)

        try:
            parsed = json.loads(cleaned_result)

            categories_filtered = {k: v for k, v in parsed.items() if k != "önemsiz"}

            if len(categories_filtered) == 0:
                st.info("Kullanıcının içerikleri kategori listemizle ilişkili değil, grafik çizilemiyor.")
                st.code(json.dumps(parsed, indent=2, ensure_ascii=False), language="json")
            else:
                df = pd.DataFrame(parsed.items(), columns=["Kategori", "Yüzde"])
                df["Yüzde (%)"] = df["Yüzde"].str.replace("%", "").astype(float)

                st.code(json.dumps(parsed, indent=2, ensure_ascii=False), language="json")

                # Yan yana grafik için sütunlar açıyoruz
                col1, col2 = st.columns(2)

                with col1:
                    st.subheader("📈 Bar Chart")
                    st.bar_chart(df.set_index("Kategori")["Yüzde (%)"])

                with col2:
                    st.subheader("🥧 Pie Chart")
                    st.pyplot(df.set_index("Kategori")["Yüzde (%)"].plot.pie(autopct="%1.1f%%", figsize=(5, 5)).figure)

        except json.JSONDecodeError as e:
            st.error("❌ JSON parse hatası! Gelen yanıt düzgün JSON değil.")
            st.text(f"JSON Hatası: {str(e)}")
            st.text("Gelen yanıt:")
            st.text(cleaned_result)
        except Exception as e:
            st.error("⚠️ Beklenmeyen hata:")
            st.text(str(e))
