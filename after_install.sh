#!/bin/sh
# update & upgrade #
#power options? suspend\hiber on lid closing and low power? #
sudo apt-get update
sudo apt-get dist-upgrade

# setup personal repo #
sudo apt-get install dpkg-dev
mkdir ~/.mydebs/
mkdir ~/bin/
echo "#!/bin/bash
 cd ~/.mydebs
 dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz'" > ~/bin/update-mydebs
sudo chmod u+x ~/bin/update-mydebs
echo deb [trusted=yes] file://$HOME/.mydebs ./ | sudo tee -a /etc/apt/sources.list

# add custom sources and PPA's #
# sudo sh -c "echo '## PPA ###' >> /etc/apt/sources.list" #
#skype # make sure you have 'apt-transport-https' installed
dpkg -s apt-transport-https > /dev/null || bash -c "sudo apt-get update; sudo apt-get install apt-transport-https -y"
curl https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
echo "deb [arch=amd64] https://repo.skype.com/deb stable main" | sudo tee /etc/apt/sources.list.d/skype-stable.list 

sudo add-apt-repository ppa:atareao/telegram -y 

#chrome x64 only
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

#anydesk, check https://anydesk.com/download for proper link, here's default Debian x64
wget -O ~/.mydebs/anydesk.deb https://download.anydesk.com/linux/anydesk_2.9.3-1_amd64.deb 

# update & upgrade #
update-mydebs
sudo apt-get update
sudo apt-get upgrade
# REMOVE some unneeded apps #
sudo apt-get remove virtualbox-guest* tomboy simple-scan gimp hexchat pidgin thunderbird transmission -y
# INSTALL new apps #
sudo apt-get install xpad qbittorrent anydesk telegram skypeforlinux intel-microcode ttf-mscorefonts-installer dconf-editor -y

# dconf settings edit # # power options #
gsettings set org.cinnamon.settings-daemon.plugins.power button-hibernate 'suspend'
gsettings set org.cinnamon.settings-daemon.plugins.power button-power 'suspend'
gsettings set org.cinnamon.settings-daemon.plugins.power critical-battery-action 'suspend'
gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend 'false'
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery '300'
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout '300'

# make some directories needed by fstab #
sudo mkdir /media/remotemachine
sudo mkdir /media/ntfs
# create samba credential files #
sudo touch /etc/samba/cred
sudo sh -c "echo 'username=yourusername' >> /etc/samba/cred"
sudo sh -c "echo 'password=yourpassword' >> /etc/samba/cred"
sudo chmod 0600 /etc/samba/cred
# add new hosts #
sudo sh -c "echo '192.168.0.105 remotemachinename' >> /etc/hosts"
# add drives to fstab #
sudo sh -c "echo 'UUID=791957C576AE1E67 /media/ntfs ntfs umask=000,utf8 0 0' >> /etc/fstab"
sudo sh -c "echo '//remoteIP/remote-dir /media/remotemachine cifs credentials=/etc/samba/cred,noperm,uid=1000,gid=1000 0 0' >> /etc/fstab"
# fixing umountcifs problem in Ubuntu on restart and shutdown #
sudo cp /home/yourusername/path/to/the/script/umountcifs /etc/init.d/
sudo update-rc.d umountcifs stop 02 0 6
sudo ln -s /etc/init.d/umountcifs /etc/rc0.d/K01umountcifs
sudo ln -s /etc/init.d/umountcifs /etc/rc6.d/K01umountcifs
# copy OpenVPN certificates to /etc/openvpn #
sudo cp /home/yourusername/.install/vpn/* /etc/openvpn
sudo /etc/init.d/openvpn restart
# time needed to connect to the VPN server (30s with reserve) and mounting drives #
sleep 30 && sudo mount -a
# turn off pc speaker beeping #
echo "blacklist pcspkr" | sudo tee -a /etc/modprobe.d/blacklist
# turn off welcome sound #
sudo -u gdm gconftool-2 --set /desktop/gnome/sound/event_sounds --type bool false
# enabling cpufreq-applet CPU frequency scaling #
sudo chmod u+s /usr/bin/cpufreq-selector
