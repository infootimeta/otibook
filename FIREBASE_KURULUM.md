# 🔥 Firebase Kurulum Rehberi - OtiBook

## 📋 Hızlı Kurulum (5 Dakika)

### 1. Firebase Console'a Git
```
https://console.firebase.google.com
```

### 2. Proje Seç veya Yeni Proje Oluştur
- "Create a project" veya mevcut projeyi seç
- Proje adı: "otibook-app"

### 3. Firestore Database'i Etkinleştir
- Sol menüden "Firestore Database" seç
- "Create database" tıkla
- "Start in test mode" seç (güvenlik kurallarını sonra ayarlarız)

### 4. Collections Oluştur (Manuel)

#### 🚀 Users Collection
```
1. "Start collection" tıkla
2. Collection ID: "users"
3. Document ID: "admin" (manuel)
4. Fields ekle:
   - nameSurname: "Admin User" (String)
   - role: "admin" (String)
   - email: "admin@otibook.com" (String)
   - createdAt: [timestamp] (Timestamp)
   - isActive: true (Boolean)
5. Save
```

#### 🎓 Students Collection
```
1. "Start collection" tıkla
2. Collection ID: "students"
3. Document ID: "auto" (otomatik)
4. Fields ekle:
   - nameSurname: "Test Öğrenci" (String)
   - qrCode: "OTI001" (String)
   - createdAt: [timestamp] (Timestamp)
   - isActive: true (Boolean)
5. Save
```

#### 📝 SessionNotes Collection
```
1. "Start collection" tıkla
2. Collection ID: "sessionNotes"
3. Document ID: "auto" (otomatik)
4. Fields ekle:
   - note_text: "Test notu" (String)
   - created_at: [timestamp] (Timestamp)
   - student_ref: [students/...] (Reference)
   - teacher_ref: [users/...] (Reference)
5. Save
```

## 🚀 Otomatik Kurulum (Script ile)

### 1. Script'i Çalıştır
```bash
cd functions
npm install
node firebase_setup.js
```

### 2. Veya Firebase Functions'a Ekle
```bash
firebase deploy --only functions
```

## 🔒 Güvenlik Kuralları (Sonra)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Test için - sonra değiştir!
    }
  }
}
```

## ✅ Kontrol Listesi

- [ ] Firebase projesi oluşturuldu
- [ ] Firestore Database etkinleştirildi
- [ ] Users collection oluşturuldu
- [ ] Students collection oluşturuldu  
- [ ] SessionNotes collection oluşturuldu
- [ ] Test verileri eklendi
- [ ] Uygulama bağlantısı test edildi

## 🎯 Sonraki Adımlar

1. **Güvenlik kurallarını ayarla**
2. **Indexes oluştur**
3. **Authentication etkinleştir**
4. **Storage etkinleştir** (medya dosyaları için)

## 💡 İpucu

İlk başta sadece **test mode** ile başla, uygulama çalışıyor mu test et, sonra güvenlik kurallarını ekle!
