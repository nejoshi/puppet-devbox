# puppet-devbox
This is a set of Puppet scripts to automate the build of a web developer box on Ubuntu.  You can install it on bare metal or virtual machine.

## Requirements
* Puppet 2.6.0 and later
* Ubuntu 11.04 Desktop (works on both 32-bit or 64-bit)

## Instructions (VirtualBox)
1. Create VM and install Ubuntu 11.04 Desktop through the ISOs (downloadable at <http://www.ubuntu.com>).
2. Whilst installing Ubuntu from the ISO, note down the username you used (or if you want to use the default for this Puppet script, it's `ubuntu`).
3. After booting into Ubuntu, install Guest Additions by going to the VirtualBox Device menu and selecting "Install Guest Additions".
4. After installing Guest Additions, reboot.
5. After the system has rebooted, open Terminal (Control + Alt + T).
6. Run:

```bash
sudo apt-get update
sudo apt-get install git puppet -y
cd /etc
sudo chown -R root:ubuntu puppet
sudo chmod -R g+w puppet
find puppet -type d | xargs sudo chmod g+s
cd puppet
git clone http://github.com/khoomeister/puppet-devbox
cd puppet-devbox
mv * ..
mv .git* ..
cd ..
rmdir puppet-devbox
cd manifests
cp site-template.pp site.pp
gedit site.pp
```

7. Read through the file & edit the settings to your liking (especially `$ubuntuUsername` if you used something other than `ubuntu`), save & quit.
8. Run `sudo puppet site.pp`

## Features
* Installs all the apps you need as a web developer
* Applies default settings to make life more fun as a developer (e.g. faster SSH connections, Git coloring, turns off Update Manager by default, etc.)
* LAMP stack uses mass virtual hosting to make setting up additional sites easier

## Applications
* LAMP ([Apache](http://httpd.apache.org), [MySQL](http://www.mysql.com) & [PHP](http://php.net))
  * Once installed, [phpMyAdmin](http://www.phpmyadmin.net) can be accessed at http://myadmin.local/
  * MySQL root password is set to `root` by default.
* [RVM](http://beginrescueend.com) + [ruby](http://www.ruby-lang.org) + useful gems like bundler, lolcat & rails
* [nodejs](http://nodejs.org) + [npm](http://npmjs.org/) + [coffee](http://jashkenas.github.com/coffee-script/) + expresso + lessc + uglifyjs
* [phantomjs](http://www.phantomjs.org/)
* [Google Chrome](http://www.google.com/chrome)
* [Sublime Text](http://www.sublimetext.com)
  * Includes Puppet & CoffeeScript code coloring
* Other useful applications are included like [ack-grep](http://betterthangrep.com), [alarm-clock-applet](http://alarm-clock.pseudoberries.com), [filezilla](http://filezilla-project.org), [flux](http://stereopsis.com/flux/), [freemind](http://freemind.sourceforge.net), [libreoffice](http://www.libreoffice.org/), [meld](http://meld.sourceforge.net), [octave](http://www.gnu.org/software/octave), [ragel](http://www.complang.org/ragel) & [x-tile](http://www.giuspen.com/x-tile).

If you don't like any of these applications, feel free to comment them out of the site.pp file.

## Metacity Shortcuts
There is a module called `metacity-shortcuts` which does two things.

* It changes the Ubuntu run dialog box's shortcut from `Alt + F2` to `Windows + Space`.  I've found this much easier on the wrists for starting up applications.
* For dual monitor setups (i.e. left & right, not up & down), it binds `Windows + S` to switch the active window to the opposite monitor and maximise it.
  * It requires one setting to be set though - `$dualMonitorsLeftMonitorWidth` which refers to the width of the left monitor.
  * If you're not using two monitors or you don't want to use this feature, set `$dualMonitorsLeftMonitorWidth` to `false` in `site.pp`.

## To setup an additional Apache virtual host:
1. Add `127.0.0.1 <hostname>.local` to `/etc/hosts`.
2. Create directory `/var/www/<hostname>.local/public`.
3. Place files in the public directory.

## If you want to develop it further...
* There is an alias called `pup` which is setup in `~/.bashrc` to make it easy to call the site.pp file as needed (i.e. `sudo puppet "/etc/puppet/manifests/site.pp"`).
