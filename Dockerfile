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
    git clone --verbose https://gitlab+deploy-token-7451311:${GITLAB_DEPLOY_TOKEN}@${GITLAB_REPO_URL} . || { echo "Clone failed"; exit 1; } && \
    echo "Repository cloned successfully"

# Copy nginx.conf to a temporary location
COPY nginx.conf /tmp/nginx.conf

# Composer cache
RUN mkdir -p /var/cache/composer && chown www-data:www-data /var/cache/composer

# Increase PHP memory limit
RUN echo 'memory_limit = 2G' > /usr/local/etc/php/conf.d/memory.ini

# Install dependencies with logging
RUN composer install --no-dev --optimize-autoloader --verbose 2>&1 | tee composer.log || \
    { echo "Composer install failed"; cat composer.log; exit 1; }

# Fix permissions
RUN chown -R www-data:www-data /var/www/html
