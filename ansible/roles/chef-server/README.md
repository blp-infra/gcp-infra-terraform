### Chef configuration methods

Workstation with chef(knife tool)-> chef server -> nodes

- on workstation : downloads.chef.io/chef-dk
includes-knife,chef-client,ohai-system profiler
(chef development kit)
```sudo dnf install chef-dk.rpm```
- in workstation

```/etc/bashrc-> export EDITOR=vi
eval "$(chef shell init bash)"

source /etc/bashrc```

### chef server installation
open source server version or use hosted chef(manage.chef.io)
```-organization>starterkit>download> upload to workstataion to connect to chef server
-from chef server download zip,-> .chef directory have knife.rb-> place it in workstations/chef-repo/.chef/knife.rb
- 
```
unziped file contain  /.chef/ (contains configuration file to connect to chef server or we have to configure)
username.pem(first user- admin),knife.rb,organizationname-validator.pem
- inside knife.rb
(directoris,url of chef server)

check configuration of workstation
```
knife client list #from workstation-> organizationname-validator
```

# install script from chef  for apache webserver
```
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
## put an html page
vi /var/www/html/index.html
  "welcome page"
```
