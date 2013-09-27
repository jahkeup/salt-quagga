quagga:
  pkg.purged:
    - require:
      - service: quagga
  service:
    - dead
  debconf.set:
    - data:
        quagga/really_stop:
          type: boolean
          value: True
    
quagga-conf:
  file.absent:
    - name: /etc/quagga
    - require:
      - pkg: quagga

quagga-init:
  file.absent:
    - name: /etc/init.d/quagga
    - require:
      - pkg: quagga