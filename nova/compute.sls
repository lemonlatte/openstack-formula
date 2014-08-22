include:
  - openstack.nova
  - openstack.prerequisites

nova-compute-prerequisites:
  pkg.installed:
    - names:
      - qemu-kvm
      - python-libvirt
      - libvirt-bin

nova-compute_user:
  user.present:
    - name: nova
    - groups:
      - nova
      - libvirtd
    - require:
      - pkg: nova-compute-prerequisites

nova-compute:
  supervisord:
    - running
    - require:
      - service: supervisor
      - file: /etc/supervisor/conf.d/nova.conf
      - pkg: nova-compute-prerequisites
      - group: libvirtd
    - watch:
      - file: nova_config
      - file: nova-compute
  file.directory:
    - name: /var/lib/nova/instances
    - user: nova
    - mode: 755
    - makedirs: True
    - require:
      - user: nova_user
