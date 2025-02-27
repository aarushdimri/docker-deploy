FROM php:8.2-fpm

# Install dependencies with clean up
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Clone repository with debug output
ARG GITLAB_DEPLOY_TOKEN
ARG GITLAB_REPO_URL
RUN echo "Attempting to clone repository..." && \
    git config --global http.sslVerify true && \
    git clone --verbose https://gitlab-ci-token:${GITLAB_DEPLOY_TOKEN}@${GITLAB_REPO_URL} . || { echo "Clone failed"; exit 1; } && \
    echo "Repository cloned successfully"

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Fix permissions
RUN chown -R www-data:www-data /var/www/html
