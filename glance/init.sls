include:
  - openstack.prerequisites

glance_repo:
  git.latest:
    - name: https://github.com/openstack/glance.git
    - rev: stable/icehouse
    - target: /opt/openstack/glance
    - require:
      - pkg: git

glance_user:
  user.present:
    - name: glance
    - fullname: Glance
    - shell: /bin/bash
    - home: /home/glance
    - group: glance

glance_db:
  mysql_database:
    - present
    - name: glance
    - require:
      - pkg: mysql-server
  mysql_user:
    - present
    - name: glance
    - host: localhost
    - password: glance
    - require:
      - pkg: mysql-server
  mysql_grants:
    - present
    - grant: all privileges
    - database: glance.*
    - user: glance
    - require:
      - mysql_database: glance_db
      - mysql_user: glance_db

/var/lib/glance/:
  file.directory:
    - user: glance
    - makedirs: True
    - mode: 755
    - recurse:
      - user
    - require:
      - user: glance_user

glance_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/glance
    - require:
      - sls: prerequisites
      - git: glance_repo
  file.directory:
    - name: /var/log/glance
    - user: glance
    - mode: 755
    - makedirs: True
    - recurse:
      - user
    - require:
      - user: glance_user

glance_config:
  file.recurse:
    - name: /etc/glance
    - user: glance
    - group: glance
    - dir_mode: 750
    - file_mode: 640
    - template: jinja
    - source: salt://openstack/glance/files/glance
    - include_empty: True
    - require:
      - user: glance_user

glance_syncdb:
  cmd.run:
    - name: /usr/local/bin/glance-manage db_sync
    - require:
      - mysql_grants: glance_db
      - cmd: glance_setup
      - file: glance_setup
      - file: glance_config

/etc/supervisor/conf.d/glance.conf:
  file.managed:
    - source: salt://openstack/glance/files/supervisor-glance.conf
    - require:
      - cmd: glance_syncdb
      - file: glance_config

salt://openstack/glance/glance-init.sh:
  cmd.script:
    - template: jinja
    - env:
      - OS_IDENTITY_API_VERSION: "3"
      - OS_TOKEN: {{pillar["admin_token"]}}
      - OS_URL: http://controller:35357/v3
    - require:
      - cmd: openstackclient_setup
      - supervisord: keystone_service

glance-api:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/glance.conf
    - watch:
      - file: glance_config

glance-registry:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/glance.conf
      - file: /var/lib/glance/
    - watch:
      - file: glance_config
