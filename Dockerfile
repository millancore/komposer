ARG PHP_VERSION

FROM php:${PHP_VERSION}-cli

# For older PHP versions, switch to the Debian archive repositories.
RUN if [ "$(php -r 'echo PHP_MAJOR_VERSION;')" -lt 8 ]; then \
    echo "deb http://archive.debian.org/debian/ buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libxml2-dev \
    zlib1g-dev \
    libpng-dev \
    libzip-dev \
    debian-archive-keyring; \
    else \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libxml2-dev \
    zlib1g-dev \
    libpng-dev \
    libzip-dev; \
    fi

# Install PHP extensions
RUN docker-php-ext-configure pcntl --enable-pcntl \
  && docker-php-ext-install pcntl soap gd zip exif


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
