# CiviCRM Drupal 8 Install Script

## Description
This project contains a script which automatically downloads all the necessary modules and dependencies needed for installing CiviCRM on an existing D8 installation. Read the full blog [here](https://docs.google.com/document/d/13isLo46tiLRi79wXfnPrH-KgQ6ypf6XCILDplRv7Ka4/edit?ts=5a9517e9#). 

## Prerequisites
- [Composer](https://getcomposer.org/) - not just the tool, but your Drupal 8 site should be using composer to manage dependencies.
- [Bower](https://bower.io/) - another package management tool. Yes, we are rich with package managers in this process.
- [Git](https://git-scm.com/) - Source control (managing the code that runs your site) is an essential part of every build, but particularly, it’s a requirement of Composer, because it uses that source control to lock down which packages you are building on.

## Important Notes
- Ensure that your ‘Vendor’ directory is outside of your document root. So your directory structure would be like this:

      your_d8_site_directory
      └── composer.json
      └── composer.lock
      └── vendor
      └── web (your document root)
      
- Create a backup of your database.

## Installation
1. Copy the `.env`, `civicrm_setup.sh` files to the root of your project.
2. Run `civicrm_setup.sh` from the project root directory **`bash ./civicrm_setup.sh`**

## `.env` file
This file contains variables necessary for `civicrm_setup.sh` such as the CiviCRM version, doc root, etc.
