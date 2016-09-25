#!/usr/bin/env bash


install_prereq() {
    sudo apt-get update -y -qq || { echo -n "Could not update apt repositories. Run apt-get update manually. Exiting." && exit 1; };
    echo "Running: apt-get install curl build-essential python...";
    sudo apt-get install -y -qq curl build-essential python  || { echo -n "Could not install packages prerequisites. Exiting." && exit 1; };

    echo "Removing former postgresql installations: apt-get purge -y postgres*...";
    sudo apt-get purge -y -qq postgres* || { echo -n "Could not remove former installation of postgresql. Exiting." && exit 1; };
    
    echo "Updating apt repository sources for postgresql..";
    sudo bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" > /etc/apt/sources.list.d/pgdg.list' || { echo -n "Could not add postgresql repo to apt." && exit 1; }
    
    echo "Adding postgresql repo key..."
    sudo wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add - || { echo -n "Could not add postgresql repo key. Exiting." && exit 1; }

    echo "Installing postgresql..."
    sudo apt-get update -qq && sudo apt-get install -y -qq postgresql postgresql-contrib libpq-dev || { echo -n "Could not install postgresql. Exiting." && exit 1; }

    return 0;
}

add_pg_user_database() {

    user_exists=$(postgres /etc/passwd |wc -l);
    if [[ $user_exists == 1 ]]; then
        sudo -u postgres bash -c "createuser -d -s -P shift || { echo -n \"Could not create database user. Exiting.\" && exit 1; }"
        sudo -u postgres bash -c "createdb -O shift shiftdb || { echo -n \"Could create database. Exiting.\" && exit 1; }"
    fi
        return 0;
}

install_node_npm() {

    echo "Installing nodejs and npm..."
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs || { echo -n "Could not install nodejs and npm. Exiting." && exit 1; }

    echo "Installing grunt-cli..."
    sudo npm install grunt-cli -g || { echo -n "Could not install grunt-cli. Exiting." && exit 1; }
    echo "Installing bower..."
    sudo npm install bower -g || { echo -n "Could not install bower. Exiting." && exit 1; }

    return 0;
}

install_shift() {

    echo "Installing SHIFT core..."
    sleep 4
    git clone -b shift_migration https://github.com/shiftcurrency/shift.git || { echo -n "Could not fetch SHIFT repo. Exiting." && exit 1; }
    cd shift && npm install --production

    return 0;
}


install_prereq
add_pg_user_database
install_node_npm
install_shift

echo ""
echo ""
echo ""
echo "Start SHIFT with: node app.js".

exit 0;
