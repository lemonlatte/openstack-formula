include:
  - openstack.prerequisites
  - openstack.nova.compute

# nova-prerequisites:
#   pkg.installed:
#     - names:
#       - libpq-dev
#       - python-tox

nova_repo:
  git.latest:
    - name: https://github.com/openstack/nova.git
    - rev: stable/icehouse
    - target: /opt/openstack/nova
    - require:
      - pkg: git

novnc_repo:
  git.latest:
    - name: https://github.com/kanaka/noVNC.git
    - target: /opt/openstack/novnc
    - require:
      - pkg: git

nova_user:
  user.present:
    - name: nova
    - fullname: Nova
    - shell: /bin/bash
    - home: /home/nova
    - group: nova

nova_db:
  mysql_database:
    - present
    - name: nova
    - require:
      - pkg: mysql-server
  mysql_user:
    - present
    - name: nova
    - host: localhost
    - password: nova
    - require:
      - pkg: mysql-server
  mysql_grants:
    - present
    - grant: all privileges
    - database: nova.*
    - user: nova
    - require:
      - mysql_database: nova_db
      - mysql_user: nova_db

# gen_nova_conf:
#   cmd.run:
#     - name: tox -egenconfig
#     - cwd: /opt/openstack/nova
#     - require:
#       - pkg: nova-prerequisites
#       - git: nova_repo
#       - pkg: mysql-server

/etc/sudoers.d/nova_sudoers:
  file.managed:
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - source: salt://openstack/nova/files/nova_sudoers

/var/lock/nova/:
  file.directory:
    - user: nova
    - mode: 755
    - makedirs: True
    - recurse:
      - user
    - require:
      - user: nova_user

nova_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/nova
    - require:
      - sls: openstack.prerequisites
      - git: nova_repo
  file.directory:
    - name: /var/log/nova
    - user: nova
    - mode: 755
    - makedirs: True
    - recurse:
      - user
    - require:
      - user: nova_user

nova_config:
  file.recurse:
    - name: /etc/nova
    - source: salt://openstack/nova/files/nova
    - user: nova
    - group: nova
    - template: jinja
    - dir_mode: 750
    - file_mode: 640
    - include_empty: True
    - require:
      - user: nova_user

nova_syncdb:
  cmd.run:
    - name: /usr/local/bin/nova-manage db sync
    - require:
      - mysql_grants: nova_db
      - cmd: nova_setup
      - file: nova_setup
      - file: nova_config

salt://openstack/nova/nova-init.sh:
  cmd.script:
    - template: jinja
    - env:
      - OS_IDENTITY_API_VERSION: "3"
      - OS_TOKEN: {{pillar["admin_token"]}}
      - OS_URL: http://controller:35357/v3
    - require:
      - cmd: openstackclient_setup
      - supervisord: keystone_service

/etc/supervisor/conf.d/nova.conf:
  file.managed:
    - source: salt://openstack/nova/files/supervisor-nova.conf
    - require:
      - cmd: nova_syncdb
      - file: nova_config

nova-api:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
      - file: /var/lock/nova/
    - watch:
      - file: nova_config

nova-cert:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
    - watch:
      - file: nova_config

nova-consoleauth:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
    - watch:
      - file: nova_config

nova-scheduler:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
    - watch:
      - file: nova_config

nova-conductor:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
    - watch:
      - file: nova_config

nova-novncproxy:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
      - git: novnc_repo
    - watch:
      - file: nova_config
