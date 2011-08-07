#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
#kernel source is needed for vbox additions

date > /etc/vagrant_box_build_time

yum -y kernel-devel-`uname -r`
yum -y clean all

# Install ruby.
wget http://192.168.0.150/ruby-enterprise-1.8.7-2010.02.tar.gz
#wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby --no-dev-docs --dont-install-useful-gems
echo 'PATH=$PATH:/opt/ruby/bin'> /etc/profile.d/rubyenterprise.sh

# As before, remove temporary files by overwriting them with zeroes so that the
# compaction (or at least compression) can be more effective.
find ./ruby-enterprise-1.8.7-2010.02/ -type f -execdir shred --remove --zero --iterations=1 '{}' \;
rm -rf ./ruby-enterprise-1.8.7-2010.02/
shred --remove --zero --iterations=1 ruby-enterprise-1.8.7-2010.02.tar.gz
#rm ruby-enterprise-1.8.7-2010.02.tar.gz

# Install Chef and Puppet.
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc

# Install the vagrant public keys.
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Install the Virtualbox Guest Additions.
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
#wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
wget http://192.168.0.150/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

# Try for a greater compaction by shredding this and writing over it with zeros.
shred --remove --zero --iterations=1 VBoxGuestAdditions_$VBOX_VERSION.iso
#rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

#reboot
#poweroff -h

exit
