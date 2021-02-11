#!/bin/bash

apt install python3
apt install python3-pip

#dependency for naabu
apt install -y libpcap-dev

#deopendency for webscreenshot
python3 -m pip install future
python3 -m install argparse

#install go
if [[ -z "$GOPATH" ]];then
echo "It looks like go is not installed, would you like to install it now"
PS3="Please select an option : "
choices=("yes" "no")
select choice in "${choices[@]}"; do
        case $choice in
                yes)

					echo "Installing Golang"
					sudo apt install -y golang
					export GOROOT=/usr/local/go
					export GOPATH=$HOME/go
					export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
					echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
					echo 'export GOPATH=$HOME/go'	>> ~/.bashrc			
					echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
					source ~/.bashrc
					sleep 1
					break
					;;
				no)
					echo "Please install go and rerun this script"
					echo "Aborting installation..."
					exit 1
					;;
	esac	
done
fi


#install chromium
echo "Installing Chromium"
sudo snap install chromium
echo "done"

mkdir ~/tools/

echo "Installing webscreenshot"
cd ~/tools/
git clone https://github.com/maaaaz/webscreenshot.git
echo "done"

echo "Installing dirsearch"
cd ~/tools/
git clone https://github.com/maurosoria/dirsearch.git
echo "done"

echo "Installing nabu"
GO111MODULE=on go get -v github.com/projectdiscovery/naabu/v2/cmd/naabu
echo "done"

echo "Installing httpx"
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
echo "done"

echo "Installing subfinder"
GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
echo "done"

echo "Installing nuclei"
GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
echo "done"
