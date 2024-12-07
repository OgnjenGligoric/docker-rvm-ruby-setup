FROM ubuntu:24.04


RUN apt-get update && \
    apt-get install -y build-essential libpq-dev nodejs curl gpg && \
    rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-lc"]

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys \
        409B6B1796C275462A1703113804BB82D39DC0E3 \
        7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://get.rvm.io | bash -s stable && \
    echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc

RUN rvm get head
RUN rvm requirements && \
    rvm pkg install openssl && \
    rvm install ruby-2.7 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-3.0 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-3.1 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-3.2 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-3.3 --with-openssl-dir=/usr/local/rvm/usr

RUN curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3B4FE6ACC0B21F32" | \
    gpg --batch --yes --dearmor -o /usr/share/keyrings/ubuntu-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://security.ubuntu.com/ubuntu bionic-security main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends libssl1.0-dev  libreadline-dev zlib1g-dev

# older versions
RUN rvm install ruby-2.4 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-2.5 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-2.6 --with-openssl-dir=/usr/local/rvm/usr
RUN rvm install ruby-2.3 --with-openssl-dir=/usr/local/rvm/usr

WORKDIR /app

COPY ./ruby-app /app

RUN ruby_version=$(grep -oP "ruby '\K[0-9]+\.[0-9]+" Gemfile) && \
    echo "Using Ruby version: $ruby_version" && \
    rvm use $ruby_version && \
    gem install bundler && \
    bundle install

COPY verify_rubies.sh .
RUN apt-get update && apt-get install -y dos2unix
RUN dos2unix /app/verify_rubies.sh
RUN chmod +x /app/verify_rubies.sh

CMD ["bash", "-lc", "bundle exec ruby app.rb -o 0.0.0.0"]
