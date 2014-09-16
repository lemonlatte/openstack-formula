

ceilometer_repo:
  git.latest:
    - name: https://github.com/openstack/ceilometer.git
    - rev: {{ pillar["openstack_rev"] }}
    - target: /opt/openstack/ceilometer
    - require:
      - pkg: git

ceilometer_user:
  user.present:
    - name: ceilometer
    - fullname: Ceilometer
    - shell: /bin/bash
    - home: /home/ceilometer
    - group: ceilometer

ceilometer_db:
  mysql_database:
    - present
    - name: ceilometer
    - require:
      - pkg: mysql-server
  mysql_user:
    - present
    - name: ceilometer
    - host: localhost
    - password: ceilometer
    - require:
      - pkg: mysql-server
  mysql_grants:
    - present
    - grant: all privileges
    - database: ceilometer.*
    - user: ceilometer
    - require:
      - mysql_database: ceilometer_db
      - mysql_user: ceilometer_db

ceilometer_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/ceilometer
    - require:
      - sls: openstack.prerequisites
      - git: ceilometer_repo
  file.directory:
    - name: /var/log/ceilometer
    - user: ceilometer
    - mode: 755
    - makedirs: True
    - recurse:
      - user
    - require:
      - user: ceilometer_user

ceilometer_config:
  file.recurse:
    - name: /etc/ceilometer
    - user: ceilometer
    - group: ceilometer
    - dir_mode: 750
    - file_mode: 640
    - template: jinja
    - source: salt://openstack/ceilometer/files/ceilometer
    - include_empty: True
    - require:
      - user: ceilometer_user

ceilometer_syncdb:
  cmd.run:
    - name: /usr/local/bin/ceilometer-dbsync
    - require:
      - mysql_grants: ceilometer_db
      - cmd: ceilometer_setup
      - file: ceilometer_setup
      - file: ceilometer_config
