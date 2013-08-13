# Quagga State

This state installs and configures quagga for whatever daemon you'd like.

Unfortunately, this state has only implemented ospfd config, if you want your
desired daemon's config to be added, simply add it in the `conf` dir and also
add the config params to the quagga pillar (along with the option: enable: True).
Your daemons config should then be automatically included.

As it stands the general config structure looks like this:

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

And if one were to add say `bgpd` it could look something like:

    quagga:
      enable_password: my_pass
      bgpd:
        asn: 22147
        peers:
          - 199.232.79.1: 64595
          - 69.43.0.1: 32432
        networks:
          - 69.43.73.0/24
          - 199.232.79.8/29
          - 199.232.79.250/32
