{% daemons = ['bgpd', 'ospfd', 'ospf6d', 'ripd', 'ripngd', 'isisd'] %}
{% quagga_conf_dir = "/etc/quagga" %}
{% daemon_conf = quagga_conf_dir + "/daemons" %}

{#
  This state expects the following pillar structure:

  quagga:
    enable_password: my_pass
    ospfd:
      enable: True
      networks:
        - 69.43.73.0/26
        - 10.0.11.0/24
      intefaces:
        eth0:
          cost: 2
#}

quagga:
  pkg.installed
    - watch:
      - file: {{ daemon_conf }}
      {% for daemon in daemons %}
      - file: /etc/quagga/{{daemon}}.conf
      {% endfor %}

  {{ quagga_conf_dir }}
    file.directory
      - user: quagga
      - group: quagga

  {{ daemon_conf }}:
    file.managed:
      - source: salt://quagga/conf/daemons
      - template: jinja
      - user: quagga
      - group: quagga
      - mode: 600
      - context:
        daemons:
        {% for daemon in daemons %}
          - {{ daemon }}
        {% endfor %}
  {{ quagga_conf_dir}}/zebra.conf:
    file.managed:
      - user: quagga
      - group: quagga
      - source: salt://quagga/conf/zebra.conf
      - template: jinja

  {% for daemon in daemons %}
  {{ quagga_conf_dir}}/{{daemon}}.conf:
    file.managed:
      - user: quagga
      - group: quagga
      - source: salt://quagga/conf/{{daemon}}.conf
      - template: jinja
  {% endfor %}