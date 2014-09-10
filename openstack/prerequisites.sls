include:
  # - openstack.openvswitch
  - openstack.supervisor

git:
  pkg.installed

python-pip:
  pkg.installed

mysql-server:
  pkg.installed:
    - names:
      - mysql-server
      - python-mysqldb
      - libmysqlclient-dev
  file.managed:
    - name: /etc/mysql/my.cnf
    - source: salt://openstack/files/my.cnf
    - mode: 644
    - require:
      - pkg: mysql-server
  service.running:
    - name: mysql
    - watch:
      - file: mysql-server

rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server
  cmd.run:
    - name: rabbitmqctl change_password guest {{ pillar["rabbitmq_passwd"] }}
    - require:
      - pkg: rabbitmq-server

base-packages:
  pkg.installed:
    - names:
      - ntp
      - python-dev
      - libssl-dev
      - libxml2-dev
      - libxslt1-dev
      - libsasl2-dev
      - libsqlite3-dev
      - libldap2-dev
      - libffi-dev
  pip.installed:
    - names:
      - pbr>=0.6,!=0.7,<1.0
      - six>=1.7.0
      - oslo.config>=1.4.0.0a3
    - require:
      - pkg: python-pip

lxml-packages:
  pkg.installed:
    - names:
      - libxslt1-dev
      - zlib1g-dev
