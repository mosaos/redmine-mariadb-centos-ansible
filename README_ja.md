# redmine-mariadb-centos-ansible

## これは？

CentOS8にRedmine4をインストールするためのAnsibleプレイブックです。  
いくつかのプラグイン/テーマも併せてインストールされます。

不要なプラグイン/テーマは適宜コメントアウトして下さい。

## システム

- Ansible 2.9
- Redmine 4.1
- CentOS 8
- MariaDB 10
- Apache 2.4

## Requirement

ミニマムインストールしたCentOS8を用意して下さい。

※お試ししたい場合、VirtualBox等の仮想環境を利用いただくとよいのではないかと思います。

## inventory

Ansibleのインベントリというものを初めて使ってみました。

- production  
  複数台構成でRedmineを構築する場合に利用します。DBとRedmineを別ホストにインストールする場合に使います。  
  インストールをするには以下の3台のホストが必要です。
  - Ansible 実行用
  - Redmine(Apache/Passenger) インストール先
  - データベース(MariaDB) インストール先
- staging  
  1台にDBもRedmine(Apache/Passenger)もインストールする場合に使います。  
  こちらは1台のホストでAnsibleの実行/Redmine&DBのインストールが可能です。

---

## インストール

### Ansibleとgit のインストール

ミニマムインストールしたCentOS8にて以下を実行します。
非rootユーザの場合、適宜 `sudo` するなどして下さい。

``` shell
dnf install -y epel-release
dnf install -y ansible git
```

### プロジェクトのclone

適当なディレクトリで、このプロジェクトを clone します。

```
git clone <project_url>
```

### 実行するロールの設定

Docker環境のインストール、および、一部プラグインはデフォルトで無効になっています。

これらもインストールしたい場合、以下ファイルを見てコメントアウトされているroleをアンコメントして下さい。

- site.yml
- redmine_plugins.yml


### 変数の設定

- インベントリファイルの設定
  - `production`  
    複数台構成でインストールする場合に設定してください。  
    インストール先のホストを設定します。  
    以下でインストール先を設定してください。
    ~~~
    [redmine_servers]
    redmine ansible_host=192.168.56.102

    [mariadb_servers]
    mariadb ansible_host=192.168.56.103
    ~~~
    また、Ansibleがssh接続するのに利用するユーザ/パスワードを設定します。インストール先にはここで設定したユーザ/パスワードでssh接続可能である必要があります。  
    ~~~
    [redmine:vars]
    ansible_user=root
    ansible_ssh_pass=Change_this
    ~~~
  - `staging`  
    一台にインストールする場合。  
    変更の必要はありません。
- `group_vars/redmine` ファイルの編集  
Redmine/MariaDBサーバで共用する設定内容を記述してあります。  
DB関連の設定を適宜変更してください。  
また、redmineのホストを設定します。  
Redmine/MariaDBを別ホスト構成にする場合、localhostではなくて、あて先ホスト名orIPアドレスに変更して下さい。
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
localhost以外での設定例(抜粋)
~~~
redmine_host: 192.168.56.102
~~~
- `group_vars/redmine-servers` ファイルの編集  
Redmine/MariaDBを別ホスト構成にする場合、localhostではなくて、DBのホスト名orIPアドレスに変更して下さい。
~~~
# Redmine settings
# DB hostname
db_host_redmine: 192.168.56.103
~~~
- `group_vars/mariadb-servers` ファイルの編集  
現状必要な設定はありません。

上記以外の設定については必要に応じて適宜変更してください。

### ansible-playbook の実行

複数台構成の場合、
``` shell
cd redmine-mariadb-centos-ansible
ansible-playbook -i production site.yml
```
一台構成の場合、

``` shell
ansible-playbook -i staging site.yml
```
を実行します。

### Redmineへのアクセス

ansible-playbook が完了したら、Redmineをインストールしたホストに  
http://redmineホスト/redmine でアクセスします。

右上のログインでログインしてください。以下でログイン可能です。

- account : admin
- password: admin

---

## プラグイン

以下のプラグインのインストールが可能です。
詳細は各プラグインのサイトを参照してください。

- [SCM Creator](https://github.com/farend/scm-creator)  
  `おすすめ`  
  Redmineサーバが、Svn/Gitサーバとしても機能するようになります。
- [Redmine Code Review Plugin](https://github.com/haru/redmine_code_review)
  `おすすめ`  
  Redmineのリポジトリ画面からソースコードレビューを行う事ができます。
- [Redmine Local Avatars](https://github.com/taqueci/redmine_local_avatars)
- [Redmine Slack](https://github.com/sciyoshi/redmine-slack.git)
- [Redmine Wiki Extensions Plugin](https://github.com/haru/redmine_wiki_extensions)  
  `おすすめ`  
- [Redmine Issue Templates Plugin](https://github.com/akiko-pusu/redmine_issue_templates)
- [Redmine per project formatting plugin](https://github.com/a-ono/redmine_per_project_formatting)
- [Redmine Theme Changer Plugin](https://github.com/haru/redmine_theme_changer)
- [Full text search plugin](https://github.com/clear-code/redmine_full_text_search)  
  `おすすめ` `要注意`  
  添付ファイルの全文検索も可能になるプラグインです。  
  さらにChuppaTextサーバと連携するとOffice文書等もインデクシングしてくれます。  
  但し、このプラグインの実行にはMariaDBの `Mroonga` エンジンが必要なため、OSデフォルトのmariadbを置き換えます。内容を理解してからインストールするのをお勧めします。  
  - 参考 : [Redmine 全文検索プラグインのすすめ<Full text search plugin>](https://www.slideshare.net/netazone/an-encouragement-of-redmine-full-text-search-plugin)
- [Redmine pluntuml macro](https://github.com/gelin/plantuml-redmine-macro)

---

## SCM Creator plugin

SCM Creatorプラグインインストール時は、Redmineのインストール先ホストに Subversion/Gitサーバもインストールされるように設定しています。

プロジェクト作成時に`SCM`で`Subversion`か`Git`を選択すると、プロジェクト作成時にプロジェクト識別子と同名のリポジトリが作成されます。
(作成先は`/var/opt/svn`、あるいは、`/var/opt/git`下)

### リポジトリURL

リポジトリのURLは以下のようになります。

#### Subversion

~~~
http://<redmine-host>/svn/<project-identifier>
~~~

#### Git

~~~
http://<redmine-host>/git/<project-identifier>.git
~~~

### 認証

認証はRedmineと同じユーザ/パスワードで認証可能です。  

- リポジトリを利用するユーザはプロジェクトのメンバーに追加してください。  
- プロジェクト識別子と異なる名前でリポジトリを作成した場合には、正しく認証が行えません。

---

## トラブルシューティング

### groonga がインストールできない

~~~ shell
TASK [redmine_plugins/redmine_full_text_search : Install groonga-release-latest] ***************************************
fatal: [redmine]: FAILED! => {"changed": false, "msg": "Failed to validate GPG signature for groonga-release-1.5.2-1.noarch"}
~~~

DBサーバ上で手動でインストールしてください。

~~~ shell
dnf install https://packages.groonga.org/centos/groonga-release-latest.noarch.rpm
~~~

この後 `dnf update` で Signature がインストールされます。

~~~
dnf update
~~~

インストール完了後、ansible-playbook を再実行してください。  
(問題なく終了したタスクはコメントアウトしてください)

### docker-ce がインストールできない

~~~ shell
TASK [Install docker] **************************************************************************************************
fatal: [docker]: FAILED! => {"changed": false, "failures": [], "msg": "Depsolve Error occured: \n 問題: problem with installed package buildah-1.11.6-7.module_el8.2.0+305+5e198a41.x86_64\n  - package buildah-1.11.6-7.module_el8.2.0+305+5e198a41.x86_64 requires runc >= 1.0.0-26, but none of the providers can be installed\n  - package containerd.io-1.3.7-3.1.el8.x86_64 conflicts with runc provided by runc-1.0.0-65.rc10.module_el8.2.0+305+5e198a41.x86_64\n  - package containerd.io-1.3.7-3.1.el8.x86_64 obsoletes runc provided by runc-1.0.0-65.rc10.module_el8.2.0+305+5e198a41.x86_64\n  - package docker-ce-3:19.03.13-3.el8.x86_64 requires containerd.io >= 1.2.2-3, but none of the providers can be installed\n  - conflicting requests\n  - package runc-1.0.0-56.rc5.dev.git2abd837.module_el8.2.0+303+1105185b.x86_64 is filtered out by modular filtering\n  - package runc-1.0.0-64.rc10.module_el8.2.0+304+65a3c2ac.x86_64 is filtered out by modular filtering", "rc": 1, "results": []}
~~~

上記のようなコンフリクトが発生している場合、ansible で解決できなかったので、以下で解決しました。

~~~ shell
dnf install -y docker-ce --allowerasing
~~~

Ansibleのdnfモジュールで `allowerasing` オプションが使えるのは `2.10` 以降。

参考 : [ansible.builtin.dnf – Manages packages with the dnf package manager &mdash; Ansible Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html)
