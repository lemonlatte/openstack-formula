include:
  - openstack.prerequisites

keystoneclient_repo:
  git.latest:
    - name: https://github.com/openstack/python-keystoneclient.git
    # - rev: stable/icehouse
    - target: /opt/openstack/python-keystoneclient
    - require:
      - pkg: git

keystoneclient_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/python-keystoneclient
    - require:
      - sls: openstack.prerequisites
      - git: keystoneclient_repo

novaclient_repo:
  git.latest:
    - name: https://github.com/openstack/python-novaclient.git
    # - rev: stable/icehouse
    - target: /opt/openstack/python-novaclient
    - require:
      - pkg: git

novaclient_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/python-novaclient
    - require:
      - sls: openstack.prerequisites
      - git: novaclient_repo

neutronclient_repo:
  git.latest:
    - name: https://github.com/openstack/python-neutronclient.git
    # - rev: stable/icehouse
    - target: /opt/openstack/python-neutronclient
    - require:
      - pkg: git

neutronclient_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/python-neutronclient
    - require:
      - git: neutronclient_repo

glanceclient_repo:
  git.latest:
    - name: https://github.com/openstack/python-glanceclient.git
    # - rev: stable/icehouse
    - target: /opt/openstack/python-glanceclient
    - require:
      - pkg: git

glanceclient_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/python-glanceclient
    - require:
      - sls: openstack.prerequisites
      - git: glanceclient_repo

cinderclient_repo:
  git.latest:
    - name: https://github.com/openstack/python-cinderclient.git
    # - rev: stable/icehouse
    - target: /opt/openstack/python-cinderclient
    - require:
      - pkg: git

cinderclient_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/python-cinderclient
    - require:
      - sls: openstack.prerequisites
      - git: cinderclient_repo

openstackclient_repo:
  git.latest:
    - name: https://github.com/openstack/python-openstackclient.git
    # - rev: stable/icehouse
    - target: /opt/openstack/python-openstackclient
    - require:
      - pkg: git

openstackclient_setup:
  cmd.run:
    - name: python setup.py install
    - cwd: /opt/openstack/python-openstackclient
    - require:
      - sls: openstack.prerequisites
      - git: openstackclient_repo
      - cmd: cinderclient_setup
      - cmd: glanceclient_setup
      - cmd: keystoneclient_setup
      - cmd: novaclient_setup
      - cmd: neutronclient_setup
