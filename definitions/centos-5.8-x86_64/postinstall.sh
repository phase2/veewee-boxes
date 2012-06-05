#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

fail() {
  echo "FATAL: $*"
  exit 1
}

# kernel source is needed for vbox additions
yum -y install kernel-devel-`uname -r`
yum -y clean all

# Install ruby
wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby --no-dev-docs --dont-install-useful-gems
echo 'PATH=$PATH:/opt/ruby/bin'> /etc/profile.d/rubyenterprise.sh

# Install chef & Puppet
echo " Install chef and puppet"
/opt/ruby/bin/gem install chef --no-ri --no-rdoc || fail "Could not install chef"
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc || fail "Could not install puppet"

# Install vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Install the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# On startup, remove HWADDR from the eth0 interface.
cp -f /etc/sysconfig/network-scripts/ifcfg-eth0 /tmp/eth0
sed "/^HWADDR/d" /tmp/eth0 > /etc/sysconfig/network-scripts/ifcfg-eth0
sed -e "s/dhcp/none/;s/eth0/eth1/" /etc/sysconfig/network-scripts/ifcfg-eth0 > /etc/sysconfig/network-scripts/ifcfg-eth1

# Add kernel parameters to prevent excessive CPU stealing under virtualization.
sed -e's/\tkernel .*/& notsc divider=10/' /boot/grub/grub.conf > /tmp/grub.conf
mv /tmp/grub.conf /boot/grub/grub.conf

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH /" /etc/sudoers

exit

