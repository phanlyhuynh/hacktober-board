FROM php:7.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents
COPY . /var/www

# Add UID '1000' to www-data
RUN usermod -u 1000 www-data

# Create system user to run Composer
RUN useradd -ms /bin/bash composer

# Copy existing application directory permissions
COPY --chown=www-data:composer . /var/www

# Set working directory
WORKDIR /var/www

# Change to composer user
USER composer

# Run Composer Install
RUN /usr/local/bin/composer install

# Generate App Key
RUN php artisan key:generate

# Migrate the DB
#RUN php artisan migrate

# Seed the Table
#RUN php artisan db:seed

# Change current user to www
USER www-data

# Expose port 8000 and start php-fpm server
EXPOSE 8000
CMD ["php-fpm"]