#!/usr/bin/env bash
# set -x

### install-delimiter.sh
### installs the delimiter and supporting tooling and creates a delimit script.
### Anthony Shackell --- Nov 15, 2023

INSTALL_DIR=~/Desktop/

echo -e "\n
*** LOCAL DELIMITER INSTALL ***\n
This script installs:
- the Delimiter into a folder in $INSTALL_DIR
- Brew (the OS X package manager)
- Python 3 
- Git
- Python virtualenv to your global python install

Sleeping for 10 seconds before proceeding. If you don't want to install these things, press ctrl-c to cancel...\n"

sleep 10

INSTALLATION_FAILED=false

# create install folder
mkdir -p "$INSTALL_DIR"
pushd "$INSTALL_DIR"
mkdir -p Delimiter
pushd Delimiter
mkdir -p input_files
mkdir -p output_files

# install support tools
echo "Checking/installing Brew..."
(which brew 1> /dev/null) || (echo "Brew is not installed. Please install using the instructions at https://brew.sh/ and try again." && exit 2)
echo "Installing Python 3..."
(brew install python3) || INSTALLATION_FAILED=true
echo "Checking/installing Git..."
(which git 1> /dev/null || brew install git) || INSTALLATION_FAILED=true
echo "Checking/installing python3 virtualenv..."
(which virtualenv 1> /dev/null || pip3 install virtualenv) || INSTALLATION_FAILED=true

if [[ $INSTALLATION_FAILED == true ]]; then
  echo "Failed installing required tooling. Review the above output and try again."
  exit 1
fi

# clone the git repo
git clone https://github.com/jeonchangbin49/De-limiter.git delimiter-source || INSTALLATION_FAILED=true
virtualenv delimiter-python-virtualenv -p python3 || INSTALLATION_FAILED=true
source "$INSTALL_DIR/Delimiter/delimiter-python-virtualenv/bin/activate" || INSTALLATION_FAILED=true
pip install -r "delimiter-source/requirements.txt" || INSTALLATION_FAILED=true
deactivate

cat > ./delimit.sh <<EOF
#!/usr/bin/env bash

### delimit.sh
### executes the delimiter for files in input dir and places the files in the output dir.
### Anthony Shackell --- Nov 15, 2023

INSTALL_DIR="$INSTALL_DIR"

source "$INSTALL_DIR/Delimiter/delimiter-python-virtualenv/bin/activate"
pushd "$INSTALL_DIR/Delimiter/delimiter-source" 1> /dev/null
python -m inference --data_root=../input_files --output_directory=../output_files
deactivate
popd 1> /dev/null

EOF

chmod +x ./delimit.sh

cat > ./README.txt <<EOF

### Local Delimiter Install ###

This installs the delimiter tool from https://github.com/jeonchangbin49/De-limiter to a local folder.
The installation dir is located at the top of the install.sh script. If you change this, rerun the 
install script and it will generate a new 'delimit.sh' script for you with the appropriate installation
directory.

After the install is completed, there will be a parent folder in the installation directory called 'Delimiter'.
Inside this parent folder, there are two directories you should be concerned with: 'input_files' and 'output_files',
which are pretty self explanatory. Place any limited files in the 'input_files' dir and run the delimiter, and delimited
files will be in the 'output_files' dir. Note that at the time of this writing, the tool only supports
44.1kHz sample rates for .wav and .mp3.

After you have placed the files you want to work with in the 'input_files' dir, run the 'delimit.sh' script in the parent
'Delimiter' directory. You can do this via the command line by navigating to this directory and executing the script.
This would look something like the following:

cd \$INSTALLATION_DIR/Delimiter
./delimit.sh

Happy delimiting!

EOF

popd
popd

if [[ $INSTALLATION_FAILED == true ]]; then
  echo "Installation failed. Review the above output and try again."
  exit 1
else
  echo "Installation Complete. To run, place files in the \"input_files\" directory and run \"delimit.sh\".
        Note that if you move this directory, the \"delimit.sh\" script will no longer work, as the installation path
        in the script will need to be updated."
fi
