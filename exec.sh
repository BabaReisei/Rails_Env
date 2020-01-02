#!/bin/sh
# 未使用dockerイメージを削除する。
docker rmi `docker images -f "dangling=true" -q`

# コンテナの起動
echo 'コンテナ起動'
docker-compose up -d

# コンテナ起動待ち
sleep 10

# Rails起動
echo 'Rails起動'
docker-compose run web rails db:create

# DockerToolBox　IP確認用
docker-machine ls