#!/bin/bash

# called by Travis CI

set -ex

composer install --no-interaction --prefer-source

# the Behat test suite will pick up the executable found in $TERMINUS_BIN_DIR
mkdir -p $TERMINUS_BIN_DIR
php -dphar.readonly=0 utils/make-phar.php terminus.phar --quiet
mv terminus.phar $TERMINUS_BIN_DIR/wp
chmod +x $TERMINUS_BIN_DIR/wp

# Travis CI doesn't come with Behat pre-installed
curl http://behat.org/downloads/behat.phar > behat.phar

# Install CodeSniffer things
./ci/prepare-codesniffer.sh

./bin/wp core download --version=$WP_VERSION --path='/tmp/terminus-test core-download-cache/'
./bin/wp core version --path='/tmp/terminus-test core-download-cache/'

mysql -e 'CREATE DATABASE wp_cli_test;' -uroot
mysql -e 'GRANT ALL PRIVILEGES ON wp_cli_test.* TO "wp_cli_test"@"localhost" IDENTIFIED BY "password1"' -uroot
