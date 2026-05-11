# syntax = docker/dockerfile:1

# ============================================================
# 本番用 Dockerfile
# 開発環境では Dockerfile.dev を使用してください
# ============================================================

ARG RUBY_VERSION=3.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# アプリケーションのディレクトリ
WORKDIR /myapp

# 本番に必要な最低限のパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        default-mysql-client \
        libjemalloc2 \
        libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 本番環境設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# ============================================================
# ビルドステージ:gem や assets をビルド
# ============================================================
FROM base AS build

# gem のビルドに必要なパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        default-libmysqlclient-dev \
        git \
        libyaml-dev \
        pkg-config \
        nodejs \
        npm && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Gemfile を先にコピーして bundle install (キャッシュ効率化)
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# アプリケーションコードをコピー
COPY . .

# bootsnap のキャッシュを生成(起動高速化)
RUN bundle exec bootsnap precompile app/ lib/

# アセットをプリコンパイル(SECRET_KEY_BASE はダミーでOK)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ============================================================
# 最終ステージ:実行用の軽量イメージ
# ============================================================
FROM base

# ビルドステージから成果物だけコピー
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /myapp /myapp

# 非rootユーザーで実行(セキュリティ対策)
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# エントリポイント(DBの準備処理が走る)
ENTRYPOINT ["/myapp/bin/docker-entrypoint"]

# サーバー起動
EXPOSE 3000
CMD ["./bin/rails", "server"]
