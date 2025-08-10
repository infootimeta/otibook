#!/bin/bash

echo "🚀 OtiBook Firebase Kurulum Script'i"
echo "======================================"

# Firebase CLI kontrol
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI bulunamadı. Kuruluyor..."
    npm install -g firebase-tools
else
    echo "✅ Firebase CLI zaten kurulu"
fi

# Firebase'e giriş
echo "🔐 Firebase'e giriş yapılıyor..."
firebase login

# Proje dizininde olduğumuzu kontrol et
if [ ! -f "firebase.json" ]; then
    echo "📁 Firebase projesi başlatılıyor..."
    firebase init firestore,functions
fi

# Functions dependencies kur
echo "📦 Functions dependencies kuruluyor..."
cd functions
npm install

# Setup function'ı deploy et
echo "🚀 Setup function deploy ediliyor..."
firebase deploy --only functions:setupOtiBook

echo "✅ Kurulum tamamlandı!"
echo "🌐 Setup function URL'i: https://us-central1-[PROJECT-ID].cloudfunctions.net/setupOtiBook"
echo ""
echo "📱 Tarayıcıda bu URL'i açarak collections'ları oluşturabilirsin!"
