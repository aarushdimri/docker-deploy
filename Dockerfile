FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-install zip pdo_mysql intl mbstring

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Clone repository
ARG GITLAB_DEPLOY_TOKEN
ARG GITLAB_REPO_URL
RUN git clone https://gitlab-ci-token:${GITLAB_DEPLOY_TOKEN}@${GITLAB_REPO_URL} .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Fix permissions
RUN chown -R www-data:www-data /var/www/html
