FROM ruby:3.2-slim

ENV WORKSPACE_DIR=/workspace
ENV REDMINE_DIR=${WORKSPACE_DIR}/redmine
ENV REDMINE_BRANCH=6.0-stable
ENV SOURCE_DIR=${REDMINE_DIR}/source

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    imagemagick \
    libmagickwand-dev \
    libmariadb-dev \
    libpq-dev \
    libsqlite3-dev \
    libyaml-dev \
    nodejs \
    npm \
    default-mysql-client \
    postgresql-client \
    sqlite3 \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 redmine \
    && useradd --uid 1000 --gid redmine --shell /bin/bash --create-home redmine

RUN mkdir ${WORKSPACE_DIR} \
    && chown redmine:redmine ${WORKSPACE_DIR}
WORKDIR ${WORKSPACE_DIR}

USER redmine

RUN git clone https://github.com/redmine/redmine.git ${REDMINE_DIR} \
    && cd ${REDMINE_DIR} \
    && git checkout ${REDMINE_BRANCH}

WORKDIR ${REDMINE_DIR}

RUN gem install bundler

COPY database.yml /workspace/redmine/config/database.yml

RUN bundle install

RUN mkdir -p ${SOURCE_DIR} \

COPY . ${SOURCE_DIR}

# ポート3000を公開
EXPOSE 3000

# デフォルトコマンド
CMD ["bash"]