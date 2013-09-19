{% set daemons = ['bgpd', 'ospfd', 'ospf6d', 'ripd', 'ripngd', 'isisd'] %}
{% set quagga_conf_dir = "/etc/quagga" %}
{% set daemon_conf = quagga_conf_dir + "/daemons" %}
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

{% if salt['pillar.get']('quagga') %}
{% set quagga = pillar['quagga'] %}

quagga:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: quagga
    - watch:
      - file: {{ daemon_conf }}
      {% for daemon in daemons %}
      {% if pillar["quagga"].get(daemon,None) %}
      - file: /etc/quagga/{{daemon}}.conf
      {% endif %}
      {% endfor %}
patch:
  pkg.installed

/etc/init.d/quagga:
    file.patch:
      - source: salt://quagga/patch/quagga-init.patch
      - hash: md5=98fcbd8be320b219d924a929b5f75475
      - require:
        - pkg: quagga
        - pkg: patch

{{ quagga_conf_dir }}:
  file.directory:
    - user: quagga
    - group: quagga
    - require:
      - pkg: quagga

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
          {{ daemon }}:
            enable: {{ quagga.get(daemon, None) and quagga[daemon].get('enable',None) or False }}
        {% endfor %}
    - require:
        - pkg: quagga

{{ quagga_conf_dir }}/zebra.conf:
  file.managed:
    - user: quagga
    - group: quagga
    - source: salt://quagga/conf/zebra.conf
    - template: jinja
    - context:
        hostname: {{ grains['host'] }}
        password: {{ quagga['enable_password'] }}
    - require:
      - pkg: quagga

{% if quagga.get('ospfd') and quagga['ospfd'].get('enable') %}
{% set ospfd = quagga['ospfd'] %}
/etc/quagga/ospfd.conf:
  file.managed:
    - user: quagga
    - group: quagga
    - source: salt://quagga/conf/ospfd.conf
    - template: jinja
    - defaults:
        ref_bw: 102400
    - context:
        router_id: {{ salt["network.ip_addrs"]()[0] }}
        hostname: {{ grains['host'] }}
        password: {{ quagga['enable_password'] }}
        networks: # which should be present if you're using quagga..
          {% for subnet in ospfd.get('networks',[]) %}
          - {{ subnet }}
          {% endfor %}
        {% if ospfd.get('interfaces', None) %}
        {% set interfaces = ospfd['interfaces'] %}
        interfaces:
          {% for interface in interfaces %}
            {{ interface }}:
              cost: {{ interfaces[interface].get('cost','102400') }}
          {% endfor %}
        {% endif %}
    - require:
      - pkg: quagga

{% endif %} # ospfd
{% endif %}
