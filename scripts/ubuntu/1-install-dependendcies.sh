#! /usr/bin/env bash

 #
 # Copyright (c) 2023 Project CHIP Authors
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.

# Install Docker Package Repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Silence user prompts about reboot and service restart required (script will prompt user to reboot in the end)
sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# TODO Comment on what dependency is required for:
packagelist=(
    ca-certificates=20230311ubuntu0.22.04.1
    docker-ce=5:24.0.7-1~ubuntu.22.04~jammy     # Test Harness uses Docker
    figlet=2.2.5-3
    g++=4:11.2.0-1ubuntu1
    gcc=4:11.2.0-1ubuntu1
    libdbus-1-dev=1.12.20-2ubuntu4.1
    libreadline-dev=8.1.2-1
    libssl-dev=3.0.2-0ubuntu1.13
    net-tools=1.60+git20181103.0eebece-1ubuntu5
    npm=8.5.1~ds-1
    python3-pip=22.0.2+dfsg-1ubuntu0.4          # Test Harness CLI uses Python              
    python3-venv=3.10.6-1~22.04                 # Test Harness CLI uses Python
    software-properties-common=0.99.22.9
    toilet=0.3-1.4
    unzip=6.0-26ubuntu3.1
)
sudo DEBIAN_FRONTEND=noninteractive sudo apt-get install ${packagelist[@]} -y

# Install Poetry, needed for Test Harness CLI
curl -sSL https://install.python-poetry.org | python3 -

# Run install-dependencies scripts in test collections
for dir in ./backend/test_collections/*
do
    if [ -d $dir ]; then 
        script=$dir/scripts/install-dependencies.sh

        # Only run install-dependencies.sh if present and it's executable
        if [ -x $script ]; then 
            echo "Running install-dependencies script: $script"
            $script
        fi
    fi
done

# We echo "complete" to ensure this scripts last command has exit code 0.
echo "Install dependencies complete"
