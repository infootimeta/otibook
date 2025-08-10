const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/**
 * Yeni bir kullanıcı Firebase Authentication'da oluşturulduğunda tetiklenir.
 * Bu fonksiyon, users koleksiyonunda kullanıcı için bir profil dökümanı oluşturur.
 *
 * Not: Bu fonksiyon, kullanıcıdan 'role' veya 'name_surname' gibi ek bilgiler
 * almaz. Sadece temel bir profil oluşturur. Uygulamamızdaki gibi kullanıcıdan
 * ek bilgi isteniyorsa, bu fonksiyon yerine client-side (istemci tarafı)
 * bir çözüm (bizim yaptığımız gibi CreateProfilePage) daha uygun olabilir.
 * Ancak bu, arka planda güvenli bir şekilde kullanıcı dökümanı oluşturmak için
 * standart bir yöntemdir.
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;

  const newUserProfile = {
    uid: uid,
    email: email || "", // E-posta olmayabilir (örn. anonim giriş)
    name_surname: displayName || "", // Genellikle sosyal medya girişlerinden gelir
    role: "parent", // Varsayılan olarak 'parent' rolü atanır.
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  try {
    await admin.firestore().collection("users").doc(uid).set(newUserProfile);
    console.log(`Successfully created profile for user: ${uid}`);
    return null;
  } catch (error) {
    console.error(`Error creating profile for user: ${uid}`, error);
    // Hata durumunda yapılacak işlemler eklenebilir.
    return null;
  }
});

// OtiBook Setup Function
exports.setupOtiBook = functions.https.onRequest(async (req, res) => {
  try {
    console.log('🚀 OtiBook Firebase Collections oluşturuluyor...');

    // 1. Users Collection - İlk admin kullanıcısı
    const adminUser = {
      nameSurname: 'Admin User',
      role: 'admin',
      email: 'admin@otibook.com',
      phoneNumber: '+905551234567',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true
    };

    const adminRef = await db.collection('users').add(adminUser);
    console.log('✅ Admin user oluşturuldu:', adminRef.id);

    // 2. Students Collection - Örnek öğrenci
    const sampleStudent = {
      nameSurname: 'Örnek Öğrenci',
      qrCode: 'OTI001',
      birthDate: new Date('2015-01-01'),
      gender: 'Erkek',
      parentIds: [],
      teacherIds: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      grade: '3. Sınıf',
      notes: 'Test öğrencisi'
    };

    const studentRef = await db.collection('students').add(sampleStudent);
    console.log('✅ Örnek öğrenci oluşturuldu:', studentRef.id);

    // 3. Session Notes Collection - Örnek not
    const sampleNote = {
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      note_text: 'İlk seans notu - test amaçlı',
      session_date: admin.firestore.FieldValue.serverTimestamp(),
      session_duration: 45,
      session_type: 'individual',
      status: 'completed',
      student_ref: studentRef,
      teacher_ref: adminRef,
      tags: ['test', 'ilk-seans']
    };

    const noteRef = await db.collection('sessionNotes').add(sampleNote);
    console.log('✅ Örnek seans notu oluşturuldu:', noteRef.id);

    res.json({
      success: true,
      message: 'OtiBook collections başarıyla oluşturuldu!',
      data: {
        adminUserId: adminRef.id,
        studentId: studentRef.id,
        noteId: noteRef.id
      }
    });

  } catch (error) {
    console.error('❌ Hata oluştu:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});
