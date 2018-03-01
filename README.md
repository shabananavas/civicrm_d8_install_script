# CiviCRM Drupal 8 Install Script

## Description
This project contains a script which automatically downloads all the necessary modules and dependencies needed for installing CiviCRM on an existing D8 installation.

## Prerequisites
- Composer - not just the tool, but your Drupal 8 site should be using composer to manage dependencies.
- Bower - another package management tool. Yes, we are rich with package managers in this process.
- Git - Source control (managing the code that runs your site) is an essential part of every build, but particularly, it’s a requirement of Composer, because it uses that source control to lock down which packages you are building on.

## Important Notes
- Ensure that your ‘Vendor’ directory is outside of your document root. So your directory structure would be like this:
      **your_d8_site_directory** <br>
      ├── composer.json<br>
      ├── composer.lock<br>
      ├── vendor<br>
      └── web (your document root)<br>
- Create a backup of your database.

## Installation
1. Copy the `.env`, `civicrm_setup.sh` files to the root of your project.
2. Run `civicrm_setup.sh` from the project root directory **`bash ./civicrm_setup.sh`**

## `.env` file
This file contains variables necessary for `civicrm_setup.sh` such as the CiviCRM version, doc root, etc.
