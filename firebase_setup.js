// Firebase Setup Script - OtiBook için gerekli collections'ları oluşturur
// Bu dosyayı Firebase Functions klasörüne koyup çalıştırabilirsin

const admin = require('firebase-admin');
const db = admin.firestore();

async function createInitialCollections() {
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

    console.log('🎉 Tüm collections başarıyla oluşturuldu!');
    console.log('📋 Oluşturulan veriler:');
    console.log('- Admin User ID:', adminRef.id);
    console.log('- Student ID:', studentRef.id);
    console.log('- Note ID:', noteRef.id);

  } catch (error) {
    console.error('❌ Hata oluştu:', error);
  }
}

// Script'i çalıştır
createInitialCollections();

module.exports = { createInitialCollections };
