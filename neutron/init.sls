include:
  - openstack.prerequisites
  # - openvswitch
  - openstack.keystone

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1
net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 0

neutron_repo:
  git.latest:
    - name: https://github.com/openstack/neutron.git
    - rev: stable/icehouse
    - target: /opt/openstack/neutron
    - require:
      - pkg: git

neutron_user:
  user.present:
    - name: neutron
    - fullname: Neutron
    - shell: /bin/bash
    - home: /home/neutron
    - group: neutron

neutron_db:
  mysql_database:
    - present
    - name: neutron
    - require:
      - pkg: mysql-server
  mysql_user:
    - present
    - name: neutron
    - host: localhost
    - password: neutron
    - require:
      - pkg: mysql-server
  mysql_grants:
    - present
    - grant: all privileges
    - database: neutron.*
    - user: neutron
    - require:
      - mysql_database: neutron_db
      - mysql_user: neutron_db

/etc/sudoers.d/neutron_sudoers:
  file.managed:
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - source: salt://openstack/neutron/files/neutron_sudoers

/var/lib/neutron:
  file.directory:
    - user: neutron
    - makedirs: True
    - mode: 755
    - recurse:
      - user
    - require:
      - user: neutron_user

/var/log/neutron:
  file.directory:
    - user: neutron
    - makedirs: True
    - mode: 755
    - recurse:
      - user
    - require:
      - user: neutron_user

neutron_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/neutron
    - require:
      - sls: openstack.prerequisites
      - git: neutron_repo
      - file: /var/lib/neutron
      - file: /var/log/neutron

openvswitch_setup:
  pkg.installed:
    - names:
      - openvswitch-switch

ovs_configuration:
  cmd.script:
    - name: salt://openstack/neutron/ovs-init.sh
    - require:
      - pkg: openvswitch_setup

neutron_config:
  file.recurse:
    - name: /etc/neutron
    - source: salt://openstack/neutron/files/neutron
    - dir_mode: 750
    - file_mode: 640
    - template: jinja
    - user: neutron
    - group: neutron
    - include_empty: True
    - require:
      - user: neutron_user


/etc/supervisor/conf.d/neutron.conf:
  file.managed:
    - source: salt://openstack/neutron/files/supervisor-neutron.conf
    - require:
      - file: neutron_config

neutron-server:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/neutron.conf
      - cmd: neutron_setup
    - watch:
      - file: neutron_config

neutron-openvswitch-agent:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/neutron.conf
      - cmd: neutron_setup
    - watch:
      - file: neutron_config

neutron-l3-agent:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/neutron.conf
      - cmd: neutron_setup
    - watch:
      - file: neutron_config

neutron-dhcp-agent:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/neutron.conf
      - cmd: neutron_setup
    - watch:
      - file: neutron_config

neutron-metadata-agent:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/neutron.conf
      - cmd: neutron_setup
    - watch:
      - file: neutron_config

salt://openstack/neutron/neutron-init.sh:
  cmd.script:
    - template: jinja
    - env:
      - OS_IDENTITY_API_VERSION: "3"
      - OS_TOKEN: {{pillar["admin_token"]}}
      - OS_URL: http://controller:35357/v3
    - require:
      - cmd: openstackclient_setup
      - supervisord: keystone_service
