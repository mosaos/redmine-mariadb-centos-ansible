# redmine-mariadb-centos-ansible

## What's this

Ansible playbook for installing Redmine4 on CentOS8.  
Several plugins and themes will also be installed.

Please comment out unnecessary plugins/themes.

## System

- Ansible 2.9
- Redmine 4.1
- CentOS 8
- MariaDB 10
- Apache 2.4

## Requirement

Prepare CentOS8 minimum installed.

*If you want to try this, You may use a virtual environment such as VirtualBox.

## Inventory

- production  
  This inventory is used when building Redmine with multiple hosts.  
  The following 3 hosts are required.
  - Ansible
  - Redmine
  - Database
- staging  
  This inventory is used when installing both DB & Redmine on one host.

---

## Install

### Install ansible and git

Execute the following on CentOS 8 with the minimum installation.   
If you are a non-root user, please `sudo` as appropriate.

``` shell
dnf install -y epel-release
dnf install -y ansible git
```

### Clone this project

Clone this project in a directory of your choice.

```
git clone <project_url>
```

### Set roles

Installation of Docker and some plugins are disabled by default.

If you want to install these, see the file below and uncomment the commented out roles.

- site.yml
- redmine_plugins.yml


### Set variables

- Edit inventory file ( `production` )  
  - `production`  
    When installing on multiple hosts, edit (& use) this.  
    Set the installation host.  
    ~~~
    [redmine_servers]
    redmine ansible_host=192.168.56.102

    [mariadb_servers]
    mariadb ansible_host=192.168.56.103
    ~~~
    Also, set the user & password that Ansible uses to connect to destination hosts with ssh.  
    ~~~
    [redmine:vars]
    ansible_user=root
    ansible_ssh_pass=Change_this
    ~~~
  - `staging`  
    When installing on one host.  
    No need to edit.
- Edit `group_vars/redmine`  
  Describes the settings shared by the Redmine/MariaDB server.  
  Please change the DB related settings as appropriate.  

  Set the host of redmine.  
  If you want to configure Redmine/MariaDB as a different host, change it to the Redmine hostname or IP address instead of localhost.
  ~~~
  # Common settings
  # root password of MariaDB
  db_passwd_root: Change_this
  # Remine database name
  db_name_redmine: db_redmine
  # MariaDB user
  db_user_redmine: user_redmine
  # MariaDB password
  db_passwd_redmine: Change_this
  # Work directory
  work_dir: /tmp/redmine-setup
  # Redmine host (Allow db connection from this address)
  # and use this vars for checking production or staging.
  redmine_host: localhost
  ~~~
- Edit `group_vars/redmine-servers`  
  If you want to configure Redmine/MariaDB as a different host, change it to the DB hostname or IP address instead of localhost.
  ~~~
  # Redmine settings
  # DB hostname
  db_host_redmine: 192.168.56.103
  ~~~
- Edit `group_vars/mariadb-servers`  
  Nothing to edit.

For settings other than the above, change as necessary.

### Run ansible playbook

In the case of multiple hosts,

``` shell
ansible-playbook -i production site.yml
```
In the case of one host,

``` shell
ansible-playbook -i staging site.yml
```

### Access to Redmine

After the installation is completed, Access to Redmine URL.

~~~
http://<redmine-host>/redmine
~~~

The initial administrator account is as follows.

- account : admin
- password: admin

---

## Plugins

The following plugins installation are available.  
Please refer the plugin site for details.

- [SCM Creator](https://github.com/farend/scm-creator)  
  `recommend`  
  If this plugin will be installed, Svn/Git server functions are enabled.
- [Redmine Code Review Plugin](https://github.com/haru/redmine_code_review)
  `recommend`  
  This plugin may be support 'Ticket-driven development'.
- [Redmine Local Avatars](https://github.com/taqueci/redmine_local_avatars)
- [Redmine Slack](https://github.com/sciyoshi/redmine-slack.git)
- [Redmine Wiki Extensions Plugin](https://github.com/haru/redmine_wiki_extensions)  
  `recommend`  
- [Redmine Issue Templates Plugin](https://github.com/akiko-pusu/redmine_issue_templates)
- [Redmine per project formatting plugin](https://github.com/a-ono/redmine_per_project_formatting)
- [Redmine Theme Changer Plugin](https://github.com/haru/redmine_theme_changer)
- [Full text search plugin](https://github.com/clear-code/redmine_full_text_search)  
  `recommend` `caution`  
  This plugin requires 'Mroonga' engine.  
  So, have to replace OS default mariadb.  
  Please install after understanding this plugin.
- [Redmine pluntuml macro](https://github.com/gelin/plantuml-redmine-macro)

---

## SCM Creator plugin

When installing the SCM Creator plugin, Subversion and Git server are also installed.

If you set `SCM` (`Subversion` or `Git`) on `New Project` page, a repository with the same name as the project identifier will be created.  
( Created under the `/var/opt/svn` or `/var/opt/git` )

### Repository URL

#### Subversion

~~~
http://<redmine-host>/svn/<project-identifier>
~~~

#### Git

~~~
http://<redmine-host>/git/<project-identifier>.git
~~~

### Authentication

You can authenticate with the same user/password as Redmine.

Add users who use the repository as members of the project.

---
