# the base image php-fpm to handle php scripts for wordpress
# wordpress is written in php and php-fpm allows nginx to process php files
# wordpress requires some php extensions to function properly:
    # php-mysql -> database connection to mriadb
    # php-xml -> fro xml parsing
        # xml parsing is the process of reading, analyzing, and extracting useful ingo from xml doc
            # extensible markup language that structures data using tags
            # <user>
            # <name>Dina</name>
            # <role>Admin</role>
            # </user>
    # php-gd or php-imagick -> for image processing
    # php-curl -> for remote http requests(API calls, updates)
    # php-zip -> plugin/theme uploads (ZIP extraction)
    # php-mbstring ->multibyte string handling
    # php-opcache -> improves performance (caching compiled PHP code)
    # unzip -> To extract the WordPress .zip file you download.
    # wget -> command line tool to download files from the web(used to download wordpress)
    # FPM is chosen over Apache because your setup will likely use Nginx as a reverse proxy.
    # The relationship between PHP-FPM and Nginx is a complementary one: they work together to serve dynamic PHP-based websites (like WordPress).

    # How they relate:

    # Nginx is the web server (reverse proxy)

    #     Handles incoming HTTP/HTTPS requests.

    #     Serves static files (images, CSS, JS, etc.) directly.

    #     Passes PHP requests (like index.php) to PHP-FPM using FastCGI protocol.

    # PHP-FPM is the PHP interpreter (process manager)

    #     Receives PHP requests from Nginx.

    #     Executes the PHP code (e.g., WordPress core files).

    #     Returns the generated HTML output back to Nginx.
# Workflow example:

#     Browser requests https://example.com/index.php.

#     Nginx checks: it's a .php file → forwards request to PHP-FPM.

#     PHP-FPM processes the file using PHP, connects to the database (if needed), generates the HTML.

#     PHP-FPM sends the HTML response back to Nginx.

#     Nginx delivers the final response to the browser.

# Why not just use Nginx alone?

#     Because Nginx cannot interpret PHP by itself — it only serves static content. PHP-FPM is the "engine" that executes PHP scripts.


FROM debian:bullseye


# Install necessary packages: PHP, PHP-FPM, and WordPress dependencies
RUN apt-get update && apt-get install -y mariadb-server mariadb-client\
    php7.4 php7.4-fpm php7.4-mysql unzip curl wget mariadb-client
RUN rm -rf /var/lib/apt/lists/*

# Sets the working directory inside the container.
# Any following commands (RUN, COPY, ADD, etc.) will be executed relative to this directory.
# If the directory doesn’t exist, Docker will create it automatically.
# Why /var/www/html?
#     This is the default document root for many web servers (Apache, Nginx).
        # For WordPress, it’s a standard place to store the website files.
WORKDIR /var/www/html

# Download and extract WordPress
# tar extracts .tar.gz files.
# Options:
# -x → extract
# -v → verbose (shows files being extracted)
# -z → gzip compressed
# -f → file to extract
# --strip-components=1 → removes the first directory level inside the archive.
# WordPress tarballs usually contain a root folder called wordpress/.
# This option ensures files are extracted directly into /var/www/html instead of /var/www/html/wordpress/.
# rm latest.tar.gz
# Cleans up the archive after extraction to keep the image smaller.
RUN wget https://wordpress.org/latest.tar.g\
    && tar -xvzf latest.tar.gz --strip-component=1\
    && rm latest.tar.gz

COPY ./requirements/wordpress/scripts.sh /usr/local/bin/

# Expose PHP-FPM port (default is 9000)
EXPOSE 9000

# Start PHP-FPM in foreground mode
ENTRYPOINT ["/usr/local/bin/scripts.sh"]

# CMD ["php-fpm7.4", "-F"]
# Provides default arguments to the ENTRYPOINT.
# Here, it tells the container to start PHP-FPM version 7.4 in foreground mode (-F):
# Foreground mode keeps the process running as PID 1, which Docker requires.
# Without -F, PHP-FPM might run in the background, and the container would exit immediately.
# You can override CMD when running the container (e.g., to run a different PHP command), but the ENTRYPOINT script still executes first.
CMD ["php-fpm7.4", "-F"]
