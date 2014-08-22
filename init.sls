include:
  - openstack.openstackclient
  - openstack.keystone
  - openstack.glance
  - openstack.nova
  - openstack.neutron
  - openstack.cinder

vagrant_user:
  user.present:
    - name: vagrant
    - shell: /bin/bash
    - home: /home/vagrant

system-openrc.sh:
  file.managed:
    - name: /home/vagrant/system-openrc.sh
    - template: jinja
    - source: salt://controller/templates/system-openrc.sh
    - user: vagrant
    - require:
      - user: vagrant_user

admin-openrc.sh:
  file.managed:
    - name: /home/vagrant/admin-openrc.sh
    - template: jinja
    - source: salt://controller/templates/admin-openrc.sh
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
