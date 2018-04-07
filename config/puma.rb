app_dir = File.expand_path("../..", __FILE__)

rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env

# socketでbindする。nginxからsocket経由で接続するため
bind "unix:///shared/tmp/sockets/puma.sock"

# ログ出力ファイルの指定
# TODO:Dockerfileに記載したディレクトリのmkdirがなぜか動かないのでそうでない場所で作っておく
stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

# pidとstateファイルの格納
pidfile "/var/run/puma/puma.pid"
state_path "/var/run/puma/puma.state"
