#!/bin/bash

# Exit on error
set -e

# Variables
MAVEN_VERSION=3.6.3
MAVEN_DIR=apache-maven-$MAVEN_VERSION
MAVEN_TAR=$MAVEN_DIR-bin.tar.gz
DOWNLOAD_URL=https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz


echo "Downloading Maven $MAVEN_VERSION..."
wget $DOWNLOAD_URL

echo "Extracting Maven..."
tar -xvzf $MAVEN_TAR

echo "Moving Maven to /usr/"
sudo mv $MAVEN_DIR /usr/

echo "Configuring environment variables..."
echo "export M2_HOME=/usr/$MAVEN_DIR" >> ~/.bashrc
echo "export PATH=\$M2_HOME/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

echo "Maven installation complete!"
mvn -version
