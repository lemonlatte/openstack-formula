include:
  - openstack.openstackclient
  - openstack.keystone
  - openstack.glance
  - openstack.nova
  - openstack.neutron
  - openstack.cinder
  - openstack.ceilometer

vagrant_user:
  user.present:
    - name: vagrant
    - shell: /bin/bash
    - home: /home/vagrant

system-openrc.sh:
  file.managed:
    - name: /home/vagrant/system-openrc.sh
    - template: jinja
    - source: salt://openstack/files/system-openrc.sh
    - user: vagrant
    - require:
      - user: vagrant_user

admin-openrc.sh:
  file.managed:
    - name: /home/vagrant/admin-openrc.sh
    - template: jinja
    - source: salt://openstack/files/admin-openrc.sh
    - user: vagrant
    - require:
      - user: vagrant_user

localhost:
  host.present:
    - order: 1
    - ip: 127.0.0.1
    - names:
      - localhost
      - controller
