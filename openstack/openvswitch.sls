
ovs-requirements:
  pkg.installed:
    - names:
      - dh-autoreconf
      - libssl-dev
      - openssl
      - wget

openvswitch-2.3.0:
  archive:
    - extracted
    - name: /opt/
    - source: http://openvswitch.org/releases/openvswitch-2.3.0.tar.gz
    - source_hash: md5=9c4d1471a56718132e0157af1bfc9310
    - tar_options: x
    - archive_format: tar
    - if_missing: /opt/openvswitch-2.3.0/

openvswitch_build:
  cmd.run:
    - name: |
        ./boot
        ./configure --prefix=/usr/local --with-linux=/lib/modules/`uname -r`/build
        make -j
        make install
        make modules_install
        modprobe gre
        modprobe openvswitch
        modprobe libcrc32c
    - cwd: /opt/openvswitch-2.3.0
