#!/bin/sh

# イメージの作成
echo 'イメージの再生成'
docker-compose build

# コンテナの起動
echo 'コンテナ起動'
docker-compose up -d

# DB作成
echo 'DB作成'
docker-compose run web rails db:create