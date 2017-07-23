#!/bin/sh
#https://www.youtube.com/watch?v=RXV6FXVL6xI

#1.Configure Update Manager
notify-send "Выстави локальные зеркала"
software-sources

#2.Install Drivers
#3.Install Microcode

notify-send "Если на этом компьютере не критично потеря сохранения (проект, курсовая, видео), то выбрать рабочие харды, CTRL+E, у каждого в третьей вкладке включить тумблер"
gnome-disks
# update & upgrade #
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
notify-send "Удалены: Сканер, Gimp, Hexchat, Pidgin, Thunderbird, Transmission"
# INSTALL new apps #
sudo apt-get install xpad qbittorrent anydesk telegram skypeforlinux intel-microcode ttf-mscorefonts-installer dconf-editor bsdtar -y
notify-send "Установлены: Qbittorrent, Anydesk, Telegram, Skype, Intel Microcode, mscorefonts, dconf"

# applets installation # # 'panel1:right:0:sticky@scollins:15' #
wget -qO- https://cinnamon-spices.linuxmint.com/files/applets/sticky@scollins.zip | sudo bsdtar -xvf- -C ~/.local/share/cinnamon/applets/

rm temp.zip
cd ~

# icons # # win10 # 
wget -qO- https://github.com/B00merang-Project/Windows-10-Icons/archive/master.zip | sudo bsdtar -xvf- -C /usr/share/icons

# check thru 'cat /proc/sys/vm/swappiness' - ’60’=mucho swappiness # # # vfs -the tendency of the kernel to reclaim the memory 'sudo cat /proc/sys/vm/vfs_cache_pressure' to check#
echo 'vm.swappiness=10
vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf

# remove hibernate from shutdown options #
sudo mv -v /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla / 
# disable user switching #
gsettings set org.cinnamon.desktop.lockdown disable-user-switching 'true'

# dconf settings edit # # power options - suspend\hiber on lid closing and low power #
gsettings set org.cinnamon.settings-daemon.plugins.power button-hibernate 'suspend'
gsettings set org.cinnamon.settings-daemon.plugins.power button-power 'suspend'
gsettings set org.cinnamon.settings-daemon.plugins.power critical-battery-action 'suspend'
gsettings set org.cinnamon.settings-daemon.plugins.power lock-on-suspend 'false'
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-battery '300'
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout '300'
# applets - no battery applet coz I don't know notebooks that can work w\o cord, no user applet #
gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:1', 'panel1:left:2:panel-launchers@cinnamon.org:3', 'panel1:left:3:window-list@cinnamon.org:4', 'panel1:right:0:systray@cinnamon.org:0', 'panel1:right:0:on-screen-keyboard@cinnamon.org:14', 'panel1:right:1:keyboard@cinnamon.org:5', 'panel1:right:2:notifications@cinnamon.org:6', 'panel1:right:3:removable-drives@cinnamon.org:7', 'panel1:right:5:network@cinnamon.org:9', 'panel1:right:8:calendar@cinnamon.org:12', 'panel1:right:9:sound@cinnamon.org:13']"
# no terminal, no software store in favorites#
gsettings set org.cinnamon favorite-apps "['firefox.desktop', 'cinnamon-settings.desktop', 'nemo.desktop']"

# keybinding #
gsettings set org.cinnamon.desktop.keybindings.media-keys logout "[]"
gsettings set org.cinnamon.desktop.keybindings.media-keys shutdown "['XF86PowerOff']"
notify-send "Чтобы Диспетчер задач открывался на Ctrl+Alt+Delete: Комбинации клавиш -> Доп. комбинации -> Добавить пользовательскую -> Название 'Диспетчер задач' ; Команда 'gnome-system-monitor' -> Привязка клавиш Ctrl+Alt+Delete"
cinnamon-settings keyboard
gsettings set org.cinnamon.desktop.keybindings.custom-keybindings.custom0 binding "['<Primary><Alt>Delete']"
gsettings set org.cinnamon.desktop.keybindings.custom-keybindings.custom0 command "gnome-system-monitor"
gsettings set org.cinnamon.desktop.keybindings.custom-keybindings.custom1 name "Диспетчер задач"

notify-send "Настроены: swappiness, убраны hibernation/switch user, при закрытии крышки\нажатии кнопки комп уходит в сон, при работе от батареи сам не отключается никогда"  
# make some directories needed by fstab #
sudo mkdir /media/Archive
sudo mkdir /media/ntfs
# give Archive read\write permissions #
sudo chmod ugo+wx /media/Archive
# add drives to fstab #
#sudo sh -c "echo 'UUID=791957C576AE1E67 /media/ntfs ntfs umask=000,utf8 0 0' >> /etc/fstab"
#sudo sh -c "echo '//remoteIP/remote-dir /media/remotemachine cifs credentials=/etc/samba/cred,noperm,uid=1000,gid=1000 0 0' >> /etc/fstab"
# enable trim on ssd #
notify-send "ТОЛЬКО ДЛЯ SSD: на всех партициях на SSD кроме swap перед 'errors' добавь 'noatime,' (без кавычек, но с запятой, без пробела)"
sudo xed /etc/fstab
# turn off pc speaker beeping #
# echo "blacklist pcspkr" | sudo tee -a /etc/modprobe.d/blacklist
# turn off welcome sound #
#sudo -u gdm gconftool-2 --set /desktop/gnome/sound/event_sounds --type bool false
notify-send "Сервис -> Параметры -> Расширенные возможности -> Отключить Java (первая галочка)"
notify-send "Сервис -> Параметры -> Память -> 64 for LibreOffice & 12 памяти на объект"
libreoffice
notify-send "Убрать лишнее из Автозагрузки: mintUpload, mintwelcome. Если карта не nVidia, то убрать Nvidia app"
cinnamon-settings startup
notify-send "В Firefox выставить желаемые поиск и домашнюю страницу"
firefox
