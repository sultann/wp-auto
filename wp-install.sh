#!/bin/bash
# Database information
DB_USER="root"
DB_PASS=""
DB_HOST="localhost"
# Path to your WordPress installs
PROJECT_PATH="/Users/$USER/Sites"






PROJECT=$1
DOMAIN="${PROJECT}.dev"
DB_NAME="${PROJECT//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}"
SITE_PATH="${PROJECT_PATH}/${PROJECT}"


if [[ $2 == "remove" ]]; then

    mysql -u root --password=root -e "DROP DATABASE IF EXISTS ${DB_NAME}"  > /dev/null 2>&1

    if [[ -d $SITE_PATH ]]; then
        echo "$SITE_PATH directory already exists"
        echo "Removing now"
        rm -rf $SITE_PATH
    fi


    echo "$DOMAIN removed completely"

	exit
fi




if [ $# -ne 1 ]; then
    echo $0: Must provide domain name as "project1"
    exit 1
fi

echo "================================================================="
echo "WordPress Installer!!"
echo "================================================================="
# Make a database, if we don't already have one
echo -e "Installing '${DOMAIN}'"
echo -e "Creating '${PROJECT}' directory"

if [[ -d $PROJECT ]]; then
    echo "$SITE_PATH directory already exists"
    echo "Removing now"
    rm -rf $SITE_PATH
fi

if [[ ! -d $PROJECT ]]; then
   mkdir -p "${PROJECT}"
fi

cd $PROJECT

#bd creating
echo -e "Creating database '${DB_NAME}'"

#mysql -u$DB_USER -p$DB_PASS -e"CREATE DATABASE $DB_NAME"

#mysql -u$DB_USER -p$DB_PASS -e"CREATE DATABASE $DB_NAME" > /dev/null 2>&1
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"  > /dev/null 2>&1
echo -e "\n DB operations done.\n\n"

# Download WP Core.
wp core download

# Generate the wp-config.php file
wp core config --dbname=$DB_NAME --dbuser=root --dbpass=root --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', true );
define( 'SCRIPT_DEBUG', true );
define( 'JETPACK_DEV_DEBUG', true );
if ( isset( \$_SERVER['HTTP_HOST'] ) && preg_match('/^(erp.)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(.xip.io)\z/', \$_SERVER['HTTP_HOST'] ) ) {
define( 'WP_HOME', 'http://' . \$_SERVER['HTTP_HOST'] );
define( 'WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST'] );
}
PHP


wp core install --url="${DOMAIN}" --title="${DOMAIN}" --admin_user=admin --admin_password=password --admin_email=manikdrmc@gmail.com


clear

#change permalink
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

#remove plugins
wp plugin delete akismet
wp plugin delete hello

#install plugins
wp plugin install developer --activate
wp plugin install debug-bar --activate
wp plugin install query-monitor --activate
wp plugin install user-switching --activate

/usr/bin/open -a "/Applications/Google Chrome.app" "http://${DOMAIN}"
