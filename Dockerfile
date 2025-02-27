FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    && docker-php-ext-install pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Clone repo using Deploy Token
ARG GITLAB_DEPLOY_TOKEN
ARG GITLAB_REPO_URL
RUN git clone https://gitlab-ci-token:${GITLAB_DEPLOY_TOKEN}@${GITLAB_REPO_URL} .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Fix permissions
RUN chown -R www-data:www-data /var/www/html
