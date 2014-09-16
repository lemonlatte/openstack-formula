include:
  - openstack.prerequisites

lvm2:
  pkg.installed

cinder_repo:
  git.latest:
    - name: https://github.com/openstack/cinder.git
    - rev: {{ pillar["openstack_rev"] }}
    - target: /opt/openstack/cinder
    - require:
      - pkg: git

cinder_user:
  user.present:
    - name: cinder
    - fullname: Cinder
    - shell: /bin/bash
    - home: /home/cinder
    - group: cinder

cinder_db:
  mysql_database:
    - present
    - name: cinder
    - require:
      - pkg: mysql-server
  mysql_user:
    - present
    - name: cinder
    - host: localhost
    - password: cinder
    - require:
      - pkg: mysql-server
  mysql_grants:
    - present
    - grant: all privileges
    - database: cinder.*
    - user: cinder
    - require:
      - mysql_database: cinder_db
      - mysql_user: cinder_db


/etc/sudoers.d/cinder_sudoers:
  file.managed:
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - source: salt://openstack/cinder/files/cinder_sudoers

cinder_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/cinder
    - require:
      - sls: openstack.prerequisites
      - git: cinder_repo
  file.directory:
    - name: /var/log/cinder
    - user: cinder
    - mode: 755
    - makedirs: True
    - recurse:
      - user
    - require:
      - user: cinder_user

lvm_config:
  file.managed:
    - name: /etc/lvm/lvm.conf
    - mode: 644
    - source: salt://openstack/cinder/files/lvm.conf
    - require:
      - pkg: lvm2

cinder_config:
  file.recurse:
    - name: /etc/cinder
    - user: cinder
    - group: cinder
    - dir_mode: 750
    - file_mode: 640
    - template: jinja
    - source: salt://openstack/cinder/files/cinder
    - include_empty: True
    - require:
      - user: cinder_user

cinder_syncdb:
  cmd.run:
    - name: /usr/local/bin/cinder-manage db sync
    - require:
      - mysql_grants: cinder_db
      - cmd: cinder_setup
      - file: cinder_setup
      - file: cinder_config

/etc/supervisor/conf.d/cinder.conf:
  file.managed:
    - source: salt://openstack/cinder/files/supervisor-cinder.conf
    - require:
      - cmd: cinder_syncdb
      - file: cinder_config

salt://openstack/cinder/cinder-init.sh:
  cmd.script:
    - template: jinja
    - env:
      - OS_IDENTITY_API_VERSION: "3"
      - OS_TOKEN: {{pillar["admin_token"]}}
      - OS_URL: http://controller:35357/v3
    - require:
      - cmd: openstackclient_setup
      - supervisord: keystone_service

cinder-api:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/cinder.conf
    - watch:
      - file: cinder_config

cinder-scheduler:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/cinder.conf
    - watch:
      - file: cinder_config

cinder-volume:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/cinder.conf
    - watch:
      - file: cinder_config
