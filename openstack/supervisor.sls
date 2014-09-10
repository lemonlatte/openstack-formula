
supervisor:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/*

