quagga:
  pkg.purged

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