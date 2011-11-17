#http://adrianbravo.tumblr.com/post/644860401

date > /etc/vagrant_box_build_time

#Updating the box
apt-get -y update
apt-get -y install linux-headers-$(uname -r)
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

#Setting up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/%sudo ALL=(ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

#Installing chef & Puppet
gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc

#Putting gems in $PATH
echo 'PATH=$PATH:/var/lib/gems/1.8/bin' >> /etc/profile.d/rubygems.sh
echo 'export PATH' >> /etc/profile.d/rubygems.sh

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

#the netboot install the virtualbox stuff so we have to remove it
/etc/init.d/virtualbox-ose-guest-utils stop
rmmod vboxguest
aptitude -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://192.168.1.200/VBoxGuestAdditions_$VBOX_VERSION.iso
#wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt

apt-get -y remove linux-headers-$(uname -r)
apt-get -y autoremove

shred --remove --zero --iterations=1 VBoxGuestAdditions_$VBOX_VERSION.iso
#rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces

# One final apt-get update so that it should work upon bringing the box up.
apt-get update

exit
