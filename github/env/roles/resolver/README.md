#resolver

- Ensure package resolvconf and dnsmasq is not installed
- Disable systemd-resolved
- Configure STATIC resolv.conf


##Examples

    - hosts: all
      become: yes
      roles:
      - role: resolver
        dns_domain: localdomain
        dns_nameservers: ['127.0.0.1', '8.8.8.8']

    - hosts: all
      become: yes
      roles:
      - role: resolver
        dns_nameservers: ['8.8.8.8']
        dns_searchs: "localdomain otherdomain"


