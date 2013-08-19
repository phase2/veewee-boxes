# Veewee Boxes
This project is for building/maintaining VirtualBoxes using veewee.

## Prerequisites

### VirtualBox
Use an operating system package to install VirtualBox, e.g.

    # apt get install virtualbox
    

### Ruby
You can use the system ruby, but you are better off using rbenv as described 
below. This has been tested with native ruby 1.9.3, jruby 1.7.2, and native 
ruby 2.0.0

#### rbenv
[rbenv](https://github.com/sstephenson/rbenv) allows us to manage Ruby 
versions. Install it by following the 
[instructions](https://github.com/sstephenson/rbenv#installation).

#### ruby-build
[ruby-build](https://github.com/sstephenson/ruby-build) is a utility for 
compiling and installing Ruby versions.  It's a plugin for rbenv that help with
installing different versions of ruby, either compiled from source or via other
means, e.g., downloading and unpacking jruby.  Follow the 
[instructions](https://github.com/sstephenson/ruby-build#installation) to 
install it.

#### Set the version
Once you have installed rbenv and ruby-build, install your desired ruby version.
For example, to use ruby 2.0:

    $ rbenv install 2.0.0-p247
    
Make that the global version:

    $ rbenv global 2.0.0-p247

### Vagrant

You can use an OS package to install Vagrant, but you can get more recent 
releases by installing Vagrant as a gem. Moreover, you will have to use a gem if
you want/need to use different versions of Ruby.

    $ gem install vagrant
    

## Veewee

### Rubygem

You can install veewee as a gem:

    $ gem install veewee
    
However, you might run into the following error:

    $ gem install veewee
 
    ERROR:  While executing gem ... (Gem::DependencyError)
       Unable to resolve dependencies: fog requires net-scp (~> 1.1)


### bundler
Using bundler allows you to manage veewee's dependencies independently from 
other gems. This seems to be the prevailing workaround for the above error.

    $ gem install bundler
    
Then use the supplied Gemfile to install veewee

    $ bundle install
    
To run veewee:

    $ bundle exec veewee

