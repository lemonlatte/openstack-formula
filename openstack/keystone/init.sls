include:
  - openstack.prerequisites

keystone_repo:
  git.latest:
    - name: https://github.com/openstack/keystone.git
    - rev: {{ pillar["openstack_rev"] }}
    - target: /opt/openstack/keystone
    - require:
      - pkg: git

keystonemiddleware_repo:
  git.latest:
    - name: https://github.com/openstack/keystonemiddleware.git
    - target: /opt/openstack/keystonemiddleware
    - require:
      - pkg: git

keystone_user:
  user.present:
    - name: keystone
    - fullname: Keystone
    - shell: /bin/bash
    - home: /home/keystone
    - group: keystone

keystone_db:
  mysql_database:
    - present
    - name: keystone
    - require:
      - pkg: mysql-server
  mysql_user:
    - present
    - name: keystone
    - host: localhost
    - password: keystone
    - require:
      - pkg: mysql-server
  mysql_grants:
    - present
    - grant: all privileges
    - database: keystone.*
    - user: keystone
    - require:
      - mysql_database: keystone_db
      - mysql_user: keystone_db

keystone_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/keystone
    - require:
      - sls: openstack.prerequisites
      - git: keystone_repo
      - file: keystone_setup
  file.directory:
    - name: /var/log/keystone
    - user: keystone
    - mode: 755
    - makedirs: True
    - recurse:
      - user
    - require:
      - user: keystone_user

keystonemiddleware_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/keystonemiddleware
    - require:
      - sls: openstack.prerequisites
      - git: keystonemiddleware_repo

keystone_config:
  file.recurse:
    - name: /etc/keystone
    - user: keystone
    - group: keystone
    - dir_mode: 750
    - file_mode: 640
    - template: jinja
    - source: salt://openstack/keystone/files/keystone
    - include_empty: True
    - require:
      - user: keystone_user

keystone_syncdb:
  cmd.run:
    - name: /usr/local/bin/keystone-manage db_sync
    - require:
      - mysql_grants: keystone_db
      - cmd: keystone_setup
      - file: keystone_config

pki_generate:
  cmd.run:
    - name: /usr/local/bin/keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
    - require:
      - cmd: keystone_setup
      - file: keystone_config

keystone_service:
  supervisord:
    - running
    - name: keystone
    - require:
      - service: supervisor
      - file: keystone_service
  file.managed:
    - name: /etc/supervisor/conf.d/keystone.conf
    - source: salt://openstack/keystone/files/supervisor-keystone.conf
    - require:
      - cmd: keystone_syncdb
      - file: keystone_config

salt://openstack/keystone/keystone-init.sh:
  cmd.script:
    - template: jinja
    - env:
      - OS_IDENTITY_API_VERSION: "3"
      - OS_TOKEN: {{pillar["admin_token"]}}
      - OS_URL: http://controller:35357/v3
    - require:
      - cmd: openstackclient_setup
      - supervisord: keystone_service
