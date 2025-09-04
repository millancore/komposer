ARG PHP_VERSION

FROM php:${PHP_VERSION}-cli-alpine

# Install git and dependencies
RUN apk add --no-cache     git     unzip     libxml2-dev     zlib-dev     libpng-dev     libzip-dev

# Install PHP extensions
RUN docker-php-ext-configure pcntl --enable-pcntl   && docker-php-ext-install pcntl soap gd zip exif


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create "/.composer/cache/" directory
RUN mkdir -p /.composer/cache/
RUN chmod -R 777 /.composer/

# Set the working directory
WORKDIR /app

# Default command to run Composer
ENTRYPOINT ["composer"]

# By default, show Composer's help
CMD ["--help"]