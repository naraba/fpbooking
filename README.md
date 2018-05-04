# Financial Planner Booking

Ruby on Railsのお勉強のためのアプリケーション。Dockerコンテナ上で動作する。

## Requirements
* docker 1.13.0+
* docker-compose

## System Overview
dockerのコンテナは4つで、リクエストを受ける側から以下の構成となっている。
* [http-portals](https://github.com/SteveLTN/https-portal)
  * HTTPS対応のため。dockerホストの80, 443をコンテナのポートにマッピングする。
* web
  * HTTPS対応前のアプリケーションのエンドポイント。Nginxを利用。
* app
  * Rackサーバ。Pumaを利用。Rubyは2.5.0、Railsは5.1.5。
* db
  * データベースサーバ。MySQL 8.0を利用。

## Setup
git cloneの後、.env.productionに[各種設定](#configuration)を行う。
```
$ git clone https://github.com/naraba/fpbooking.git
$ cd fpbooking
$ cp .env.production.sample .env.production
```

dockerイメージを作成。
```
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
```

fpbooking_dbを実行してrootユーザでデータベースに接続し、.env.productionで設定したユーザを作成。
```
> create user foobar@'%' identified by 'password';
> grant all on myapp_production.* to foobar@'%' identified by 'password';
```

データベースを初期化。
```
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm app rails db:create
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm app rails db:migrate
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm app rails db:seed
```

アプリケーションの起動。
```
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

アプリケーションの停止。
```
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml down
```

## Configuration
.env.productionには以下を設定する。

* DOMAINS
  * アプリケーションを公開するドメイン
* MYSQL_ROOT_PASSWORD
  * データベースのrootパスワード
* MYSQL_MYAPP_USER
  * アプリケーション接続用のデータベースユーザ
* MYSQL_MYAPP_PASSWORD
  * アプリケーション接続用のパスワード
* WEB_CONCURRENCY
  * Pumaのworkers
* RAILS_MAX_THREADS
  * Pumaのthreadsおよびdatabase.ymlのpool
* SECRET_KEY_BASE
  * rails secretの出力結果

## Initial Data
データベースの初期状態（rails db:seedを実行した直後）には以下のデータが存在する。予約枠については、現実の日付とリンクしているのでdb:seed実行時に基づいて、その三日前から一ヶ月後までの日に対して予約枠を登録する。
* フィナンシャルプランナー3人分
  * メールアドレス（#は1..3の数値）：　fp-#@example.com
  * パスワード：　password
  * メールアドレスが奇数番号のFPは月・水・金、偶数番号のFPは火・木・土の12時台を除くフルタイムで予約枠を登録済み
* ユーザー10人分
  * メールアドレス（#は1..10の数値）：　user-#@example.com
  * パスワード：　password
  * いずれのユーザーも予約なし
* 追加で以下のFP、ユーザーも
  * FPはfp@example.com、パスワードtesttest
  * ユーザーはuser@example.com、パスワードはtesttest

## Usage
* フィナンシャルプランナー
  * トップページ右下の「このサイトについて」からアカウントの登録もしくはログインページに行って、ログインする。
  * ログイン後のページの記載に沿って、ユーザーからの予約を受け付ける枠を登録する。
* ユーザー
  * トップページ中央のアカウント登録または右上のログインページに行って、ログインする。
  * ログイン後のページの記載に沿って、フィナンシャルプランナーの空き枠に対して予約を入れる。
