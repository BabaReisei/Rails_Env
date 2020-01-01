#!/bin/sh

# ↓修正箇所　プロジェクトの親ディレクトリ（相対パス）
PROJECT_NAME='src'
DB_PASSWORD='password'
DB_ROOT='root'
DB_PORT='3306'
WEB_PORT='3000'
# ↑修正個所

# 以下は有識者以外修正不可
APP_HOME='../'${PROJECT_NAME}

# 起動中のコンテナを停止し、コンテナと作成済みのdockerイメージを削除する。
docker stop `docker ps -a -q`
docker rm -f `docker ps -a -q`
docker rmi `docker images -f "dangling=true" -q`

echo '新規プロジェクト作成: '${PROJECT_NAME}

# プロジェクトディレクトリが既にある場合は確認の上ディレクトリを削除
if [ -e ${APP_HOME} ]; then 
    echo ${PROJECT_NAME}'を削除してもよろしいですか？（y/n）'
    read ANS
    ANS=$(tr '[a-z]' '[A-Z]' <<< $ANS)
    if [ ${ANS} = "Y" -o ${ANS} = "YES" ] ; then
        echo 'ディレクトリ削除開始'
        rm -rf ${APP_HOME}
        echo 'ディレクトリ削除終了'
        mkdir -p ${APP_HOME}
    else
        echo '終了します'
        exit 0
    fi
fi

# ファイルコピー
cp ./Dockerfile ${APP_HOME}/Dockerfile
cp ./Gemfile ${APP_HOME}/Gemfile
cp ./Gemfile.lock ${APP_HOME}/Gemfile.lock
cp ./sh_exec_mac.sh ${APP_HOME}/exec.sh
cp ./sh_stop_mac.sh ${APP_HOME}/stop.sh


# docker-compose.yml作成
echo 'docker-compose.yml作成'
sed -e 's/DB_PASSWORD/'${DB_PASSWORD}'/g'\
    -e 's/DB_ROOT/'${DB_ROOT}'/g'\
    -e 's/DB_PORT/'${DB_PORT}'/g'\
    -e 's/WEB_PORT/'${WEB_PORT}'/g' ./docker-compose.yml > ${APP_HOME}/docker-compose.yml

# docker-compose実行
cd ${APP_HOME}
echo 'docker-compose実行'
docker-compose run web rails new . --force --database=mysql --skip-bundle

# database.yml作成
echo 'datebase.yml作成'
sed -e 's/DB_ROOT/'${DB_ROOT}'/g'\
    -e 's/DB_PASSWORD/'${DB_PASSWORD}'/g' ../dockerWork/database.yml > ./config/database.yml

# イメージの作成
echo 'イメージの再生成'
docker-compose build

# コンテナの起動
echo 'コンテナ起動'
docker-compose up -d

# DB作成
echo 'DB作成'
docker-compose run web rails db:create