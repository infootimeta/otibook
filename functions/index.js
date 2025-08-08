const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

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
