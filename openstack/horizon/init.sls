include:
  - openstack.prerequisites

django_openstack_auth_repo:
  git.latest:
    - name: https://github.com/openstack/django_openstack_auth.git
    - target: /opt/openstack/django_openstack_auth
    - require:
      - pkg: git

django_openstack_auth_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/django_openstack_auth
    - require:
      - sls: openstack.prerequisites
      - git: django_openstack_auth_repo

horizon_repo:
  git.latest:
    - name: https://github.com/openstack/horizon.git
    - rev: stable/icehouse
    - target: /opt/openstack/horizon
    - require:
      - pkg: git

horizon_user:
  user.present:
    - name: horizon
    - fullname: Horizon
    - shell: /bin/bash
    - home: /home/horizon
    - group: horizon

horizon_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/horizon
    - require:
      - git: horizon_repo
      - cmd: django_openstack_auth_setup
  file.directory:
    - name: /var/log/horizon
    - user: horizon
    - mode: 755
    - makedirs: True
    - require:
      - user: horizon_user

horizon_config:
  file.managed:
    - name: /opt/openstack/horizon/openstack_dashboard/local/local_settings.py
    - user: horizon
    - group: horizon
    - file_mode: 640
    - template: jinja
    - source: salt://openstack/horizon/files/local_settings.py
    - include_empty: True
    - require:
      - user: horizon_user
      - git: horizon_repo

/etc/supervisor/conf.d/horizon.conf:
  file.managed:
    - source: salt://openstack/horizon/files/supervisor-horizon.conf
    - require:
      - file: horizon_config

horizon_service:
  supervisord:
    - running
    - name: horizon
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/horizon.conf
