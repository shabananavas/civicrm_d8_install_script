#!/bin/bash

user_civicrm_version() {
  if [ -z "${CIVICRM_VERSION}" ]; then
    read -p "Enter the CiviCRM version to download (ie: 4.7.30): " USER_CIVICRM_VERSION
  else
    read -p "Enter the CiviCRM version to download (ie: 4.7.30), or hit enter to keep \"${CIVICRM_VERSION}\": " USER_CIVICRM_VERSION
    [ -z "${USER_CIVICRM_VERSION}" ] && USER_CIVICRM_VERSION="${CIVICRM_VERSION}"
  fi
  
  if [ -z "${USER_CIVICRM_VERSION}" ]; then
    echo "Version can not be empty"
    return 1
  fi
  
  echo "${USER_CIVICRM_VERSION}"
}

user_github_token() {
  if [ -z "${GITHUB_TOKEN}" ]; then
    read -p "Enter your github personal access token: " USER_GITHUB_TOKEN
  else
    read -p "Enter your github personal access token, or hit enter to keep \"${GITHUB_TOKEN}\": " USER_GITHUB_TOKEN
    [ -z "${USER_GITHUB_TOKEN}" ] && USER_GITHUB_TOKEN="${GITHUB_TOKEN}"
  fi
  
  if [ -z "${USER_GITHUB_TOKEN}" ]; then
    echo "Github token can not be empty"
    return 1
  fi
  
  echo "${USER_GITHUB_TOKEN}"
}

user_doc_root() {
  if [ -z "${DOC_ROOT}" ]; then
    read -p "Enter a doc root for the site (e.g. wwwroot, web).=: " USER_DOC_ROOT
  else
    read -p "Enter a doc root for the site (e.g. wwwroot, web), or hit enter to keep \"${DOC_ROOT}\": " USER_DOC_ROOT
    [ -z "${USER_DOC_ROOT}" ] && USER_DOC_ROOT="${DOC_ROOT}"
  fi
  
  echo "${USER_DOC_ROOT}"
}

main() (
  set -e
  echo -e "\n** This script helps to download all the necessary modules and dependencies to install CiviCRM on a Drupal 8 installation **\n"
  echo "Note: Make sure this file is in your repo root."
  echo -e "\n"
  
  CIVICRM_VERSION=$(user_civicrm_version) || return 1
  if grep -q "CIVICRM_VERSION=" .env; then
    sed -i -e "s/CIVICRM_VERSION=.*/CIVICRM_VERSION=${CIVICRM_VERSION}/g" .env
  else
    echo "CIVICRM_VERSION=${CIVICRM_VERSION}" >> .env
  fi
  echo "...\"${CIVICRM_VERSION}\" chosen as CiviCRM version"

  GITHUB_TOKEN=$(user_github_token) || return 1
  if grep -q "GITHUB_TOKEN=" .env; then
    sed -i -e "s/GITHUB_TOKEN=.*/GITHUB_TOKEN=${GITHUB_TOKEN}/g" .env
  else
    echo "GITHUB_TOKEN=${GITHUB_TOKEN}" >> .env
  fi
  echo "...\"${GITHUB_TOKEN}\" chosen as github access token"

  DOC_ROOT=$(user_doc_root) || return 1
  if grep -q "DOC_ROOT=" .env; then
    sed -i -e "s/DOC_ROOT=.*/DOC_ROOT=${DOC_ROOT}/g" .env
  else
    echo "DOC_ROOT=${DOC_ROOT}" >> .env
  fi
  if [ -z "${DOC_ROOT}" ]; then
    echo "...Doc root is the same as the project root"
  else
    echo "...\"${DOC_ROOT}\" chosen as doc root"
  fi


  echo "***Setting up composer configurations...***"
    # Add our github authentication token.
    composer config github-oauth.github.com "${GITHUB_TOKEN}"
    # Repo Configuration.
    composer config repositories.phpword vcs https://github.com/dsnopek/PHPWord.git
    composer config repositories.civicrm-core vcs https://github.com/mydropwizard/civicrm-core.git
    composer config repositories.civicrm-drupal '{
      "type": "package",
      "package": {
        "name": "drupal/civicrm-drupal",
        "type": "drupal-module",
        "version": "dev-roundearth",
        "source": {
          "type": "git",
          "url": "https://github.com/mydropwizard/civicrm-drupal.git",
          "reference": "8.x-master"
        }
      }
    }'
    composer config repositories.zetacomponents-mail vcs https://github.com/civicrm/zetacomponents-mail.git
    composer config repositories.topsort vcs https://github.com/totten/topsort.php.git
  echo "***Downloading modules and dependencies...***"
    composer require 'phpoffice/PHPWord:dev-zend-version as 0.13.0'
    composer require "civicrm/civicrm-core:dev-roundearth-$CIVICRM_VERSION as $CIVICRM_VERSION"
    composer require drupal/civicrm-drupal:dev-roundearth
    # Install dependencies.
    cd vendor/civicrm/civicrm-core
    bower install --allow-root
  echo "***Downloading the latest CiviCRM Drupal package to copy necessary files...***"
    # Download CiviCRM Drupal.
    cd ../../../
    wget -O /tmp/civicrm.tar.gz https://download.civicrm.org/civicrm-$CIVICRM_VERSION-drupal.tar.gz
    tar -xzf /tmp/civicrm.tar.gz -C /tmp
    mkdir -p vendor/civicrm/civicrm-core/
    cp -r /tmp/civicrm/packages vendor/civicrm/civicrm-core/
    cat /tmp/civicrm/civicrm-version.php | sed -e 's/Drupal/Drupal8/' > vendor/civicrm/civicrm-core/civicrm-version.php
    cp -r /tmp/civicrm/sql vendor/civicrm/civicrm-core/
    cp /tmp/civicrm/civicrm.config.php vendor/civicrm/civicrm-core/
    cp /tmp/civicrm/CRM/Core/I18n/SchemaStructure.php vendor/civicrm/civicrm-core/CRM/Core/I18n/
    cp /tmp/civicrm/install/langs.php vendor/civicrm/civicrm-core/install/
    cp /tmp/civicrm/./templates/CRM/common/version.tpl vendor/civicrm/civicrm-core/templates/CRM/common/
    rm -rf /tmp/civicrm.tar.gz /tmp/civicrm
  echo "***Copying assets...***"
    # Copy CiviCRM assets.
    cd "${DOC_ROOT}"
    asset_source=./vendor/civicrm/civicrm-core
    asset_dest=./web/libraries/civicrm
    mkdir -p $asset_dest
    rsync -mr --include='*.'{html,js,css,svg,png,jpg,jpeg,ico,gif,woff,woff2,ttf,eot} --include='*/' --exclude='*' $asset_source/ $asset_dest/
    rm -rf $asset_dest/tests
    cp -r $asset_source/extern $asset_dest/
    cp $asset_source/civicrm.config.php $asset_dest/
    cat << EOF > $asset_dest/settings_location.php
      <?php

      define('CIVICRM_CONFDIR', '../../../sites');
      EOF
    chmod 0775 sites/default
    cd ../
  echo "***All CiviCRM modules and dependencies have been successfully downloaded.***"
  echo "***Refer to https://github.com/shabananavas/civicrm_d8_install_script (Steps 3-5) for instructions on enabling CiviCRM and completing the installation.***"
)

source ./.env
main
