#!/bin/bash

BUILD_DIR="_site"
DEPLOY_BRANCH="gh-pages"

echo "🔧 Membangun Jekyll..."
bundle config set --local path 'vendor/bundle'
bundle exec jekyll build || { echo "❌ Build gagal"; exit 1; }

# Simpan nama branch aktif
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

echo "🔀 Checkout ke branch $DEPLOY_BRANCH..."
git stash push -m "stash-before-deploy"
if git show-ref --verify --quiet refs/heads/$DEPLOY_BRANCH; then
  git checkout $DEPLOY_BRANCH
else
  git checkout --orphan $DEPLOY_BRANCH
  git reset --hard
fi

echo "🧹 Menghapus semua isi branch lama..."
git rm -rf . > /dev/null 2>&1

echo "📦 Menyalin isi _site/ ke branch $DEPLOY_BRANCH..."
cp -r "$BUILD_DIR/." .

echo "📤 Commit dan push..."
git add .
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ Tidak ada perubahan."
git push origin $DEPLOY_BRANCH --force

echo "🔙 Kembali ke branch sebelumnya..."
git checkout "$CURRENT_BRANCH"
git stash pop || true

echo "✅ Selesai! Situs aktif di: https://wahyulingu.github.io"
