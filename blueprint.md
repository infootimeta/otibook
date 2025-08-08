# Proje Adı: otibook - Dijital Gelişim Defteri

## 1. Proje Vizyonu ve Genel Bakış

Bu proje, özel rehabilitasyon merkezlerinde görev yapan öğretmenlerin, aynı öğrenciyle çalışan farklı meslektaşları arasındaki iletişim ve veri akışı sorunlarını çözmeyi amaçlamaktadır. Geleneksel kağıt defterlerin yerini alacak olan **otibook**, öğretmenler için saniyeler içinde not eklemeyi mümkün kılan, son derece hızlı ve verimli bir dijital gelişim defteridir. Aynı zamanda, veliler için çocuklarının gelişim süreçlerini şeffaf bir şekilde takip edebilecekleri bir platform sunar. Uygulamanın temel başarı kriteri, bir öğretmenin ders aralarında minimum zaman harcayarak sisteme veri girebilmesidir.

## 2. Temel Mimari ve Teknolojiler

Uygulama, Google'ın Firebase platformu üzerine inşa edilmiş, ölçeklenebilir ve güvenli bir Flutter mobil uygulaması olarak tasarlanmıştır.

- **Frontend:** Flutter
- **Backend & Altyapı:** Firebase

### Firebase Servisleri
- **Firebase Authentication:** E-posta/Şifre, Google ve Apple kimlik doğrulama yöntemleri ile güvenli kullanıcı girişi.
- **Firestore Database:** Tüm uygulama verilerinin (kullanıcılar, öğrenciler, ders notları) saklanacağı NoSQL veritabanı.
- **Firebase Storage:** Ders notlarına eklenecek resim, kısa video ve ses kaydı gibi medya dosyalarını depolamak için.
- **Firebase Functions:** Otomatik arka plan işlemleri için (örn. yeni kullanıcı kaydında otomatik profil oluşturma).

### Firestore Veri Modeli

#### `users` Koleksiyonu
- **Açıklama:** Her döküman bir kullanıcıyı temsil eder (ID: Auth UID).
- **Alanlar:**
  - `uid`: String
  - `email`: String
  - `name_surname`: String
  - `role`: String ('teacher', 'parent', 'admin')
  - `created_at`: Timestamp

#### `students` Koleksiyonu
- **Açıklama:** Her döküman bir öğrenciyi temsil eder.
- **Alanlar:**
  - `name_surname`: String
  - `qr_code_data`: String (Benzersiz)
  - `parent_ref`: DocumentReference (-> users)
  - `assigned_teacher_refs`: List<DocumentReference> (-> users)
  - `created_at`: Timestamp

#### `session_notes` Koleksiyonu
- **Açıklama:** Her döküman tek bir ders notunu temsil eder.
- **Alanlar:**
  - `created_at`: Timestamp
  - `note_text`: String (Boş olabilir)
  - `media_url`: String (Storage dosya yolu, boş olabilir)
  - `audio_url`: String (Storage dosya yolu, boş olabilir)
  - `student_ref`: DocumentReference (-> students)
  - `teacher_ref`: DocumentReference (-> users)


## 3. Stil, Dizayn ve Özellikler (MVP V1.0)

### Kullanıcı Akışları ve Ekranlar

1.  **Kayıt ve Profil Oluşturma Akışı:**
    -   `AuthPage`: Giriş ve kayıt seçeneklerinin sunulduğu ana ekran (E-posta, Google, Apple).
    -   `RegisterPage`: E-posta ile kayıt formu.
    -   `CreateProfilePage`: Yeni kaydolan kullanıcının adını, soyadını girdiği ve rolünü ('teacher', 'parent', 'admin') seçtiği ekran.
    -   `RoleGatePage`: Giriş yapmış kullanıcının rolüne göre doğru ana sayfaya (`TeacherHomePage`, `ParentHomePage`, `AdminDashboardPage`) yönlendirilmesini sağlayan mantıksal bir kapı.

2.  **Öğretmen Çekirdek Akışı:**
    -   `TeacherHomePage`: Öğretmene atanmış öğrencilerin bir listesini ve ders notu eklemek için büyük, belirgin bir **"QR Kod Okut"** butonunu içerir.
    -   `StudentDetailPage`: QR kod okutulduğunda veya listeden bir öğrenci seçildiğinde açılan, öğrencinin tüm geçmiş ders notlarının kronolojik (en yeniden en eskiye) olarak listelendiği sayfa.
    -   `AddNotePage`: Öğrencinin `StudentDetailPage`'inden ulaşılan, metin, fotoğraf (galeriden veya kameradan) ve ses kaydı eklemeye olanak tanıyan not oluşturma sayfası.

3.  **Veli Akışı:**
    -   `ParentHomePage`: Velinin kendi çocuğuna ait `StudentDetailPage`'ini gördüğü, sadece okuma yetkisine sahip olduğu arayüz.

4.  **Yönetici Akışı:**
    -   `AdminDashboardPage`: Yeni kullanıcı ve öğrenci oluşturma, mevcutları listeleme/düzenleme ve en önemlisi öğretmen-öğrenci atamalarını yapmak için yönetim araçlarının bulunduğu bir panel.

### Kritik Fonksiyonellikler
- **Hızlı QR Kod Erişimi:** Uygulamanın en kritik özelliği. Öğretmen ana sayfasından kamerayı anında açarak QR kodu okutur ve ilgili öğrencinin detay sayfasına saniyeler içinde ulaşır.
- **Rol Tabanlı Arayüz (Role-Based UI):** Arayüzdeki elemanlar, butonlar ve görülebilen veriler, giriş yapan kullanıcının `users` koleksiyonundaki `role` alanına göre dinamik olarak şekillenir.
- **Çoklu Not Formatı:** `AddNotePage` üzerinden metin, resim ve ses kaydı formatında notlar oluşturulup Firebase Storage'a yüklenebilir.

## Mevcut Görev: Proje Kurulumu ve Bağımlılıkların Eklenmesi

1.  **Firebase Projesi Kurulumu:** Firebase projesinin ve gerekli servislerin (Auth, Firestore, Storage) konsol üzerinden aktif edilmesi.
2.  **Flutter Projesi Yapılandırması:** `flutterfire configure` komutu ile projenin Firebase'e bağlanması.
3.  **Gerekli Paketlerin Eklenmesi:** `pubspec.yaml` dosyasına aşağıdaki temel bağımlılıkların eklenmesi:
    - `firebase_core`: Firebase bağlantısı için temel paket.
    - `firebase_auth`: Kimlik doğrulama işlemleri için.
    - `cloud_firestore`: Firestore veritabanı işlemleri için.
    - `firebase_storage`: Medya dosyalarını depolamak için.
    - `go_router`: Deklaratif ve güçlü bir yönlendirme (routing) yönetimi için.
    - `provider`: State management ve dependency injection için.
    - `qr_code_scanner`: QR kod okuma fonksiyonelliği için.
    - `google_fonts`: Modern ve okunaklı metin stilleri için.
    - `image_picker`: Galeriden veya kameradan resim seçmek için.
    - `record`: Ses kaydı yapmak için.
4.  **Proje Dizin Yapısının Oluşturulması:** Kodun organize ve ölçeklenebilir olması için `lib` klasörü altında mantıksal bir dizin yapısı (`auth`, `core`, `features`, `models`, `providers`, `utils` vb.) oluşturulması.
5.  **Firebase Emulators Kurulumu:** Geliştirme sürecini hızlandırmak ve maliyetleri düşürmek için yerel Firebase emulator'lerinin (`Auth`, `Firestore`, `Storage`) yapılandırılması.
