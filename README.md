# Komposer

Komposer is a simple yet powerful tool that allows you to run Composer commands in isolated environments using Docker. It dynamically builds Docker images for the specified PHP version, ensuring that your project's dependencies are managed consistently across different environments.

## Prerequisites

Before using Komposer, you must have Docker installed and running on your system.

- [Docker Installation Instructions](https://docs.docker.com/engine/install/)

## How to Use

The `komposer` script is the main entry point for this tool. You can run it directly from your terminal.

### Syntax

```bash
./komposer [OPTIONS] <php_version> <composer_command>
```

### Arguments

-   `<php_version>`: **(Required)** The PHP version you want to use (e.g., `8.1`, `8.2`, `8.3`). Komposer will automatically build a Docker image for this version if it doesn't already exist.
-   `<composer_command>`: **(Required)** The Composer command you want to execute (e.g., `install`, `update`, `require monolog/monolog`).

### Options

-   `--force-build`: Forces the rebuild of the Docker image, even if an image for the specified PHP version already exists.
-   `--no-build`: Prevents the automatic building of the Docker image. The script will only use an existing image. If the image doesn't exist, the script will exit with an error.
-   `--help`: Displays the help message with usage instructions.

## Examples

### Initializing a new project

To initialize a new Composer project in the current directory, you can run:

```bash
./komposer 8.2 require monolog/monolog
```

This command will:
1.  Build a Docker image with PHP 8.2 (if it doesn't exist).
2.  Run the `composer require monolog/monolog` command inside the container.
3.  Mount the current directory as a volume, so the `composer.json`, `composer.lock`, and `vendor` directory are created on your local machine.

### Installing dependencies

If you have an existing `composer.json` file, you can install the dependencies with:

```bash
./komposer 8.1 install
```

### Updating dependencies

To update your project's dependencies to the latest versions allowed by your `composer.json`, run:

```bash
./komposer 8.3 update
```

### Forcing a rebuild of the Docker image

If you have made changes to the `Dockerfile` or want to ensure you have the latest base image, you can force a rebuild:

```bash
./komposer --force-build 8.2 install
```

## How It Works

Komposer uses a `Dockerfile` to build a Docker image for the specified PHP version. The `komposer` script then runs a container based on this image, mounting the current working directory to `/app` inside the container. This allows Composer to manage your project's dependencies as if it were running directly on your machine, but with the isolation and consistency of Docker.

## Advanced Usage

### Using a specific Dockerfile for a PHP version

Komposer allows you to use a dedicated Dockerfile for a specific PHP version. This is useful when you need to install different extensions or have a different configuration for a particular PHP version.

To use a specific Dockerfile, create a file named `Dockerfile.php<version>` in the same directory as the `komposer` script. For example, if you want to use a custom Dockerfile for PHP 8.1, you would create a file named `Dockerfile.php8.1`.

When you run `komposer` with that PHP version, it will automatically detect and use the specific Dockerfile. For example:

```bash
./komposer 8.1 install
```

This command will use `Dockerfile.php8.1` to build the Docker image for PHP 8.1. If a specific Dockerfile is not found, Komposer will fall back to the generic `Dockerfile`.

## Testing

The project includes a test script (`test.sh`) to verify the functionality of Komposer. To run the tests, simply execute the script:

```bash
./test.sh
```