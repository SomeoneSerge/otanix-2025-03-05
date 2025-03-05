OtaNix: Secret Management
===

`@SomeoneSerge`

![](./qr.png)

* * *

NixOS
---

- Declarative:
    - static configuration,
    - atomic switch.
- Secrets
    - `/nix/store` is world-readable
    - `passwordFile`: make secrets state again
        - Brings back the state's complexity
        - `services.openssh.hostKeys`: auto-generate secrets ad hoc
        - multi-node: requires multiple switches to synchronize the states

* * *

agenix, sops-nix
---

Generate secrets in advance, encrypt them

* * *

sops-nix demo
---

- `nvim .sops.yaml` (configure recipients)
    - developer's keys (cf. e.g.)
    - target machine's ssh host keys
- `sops vms/yggi/secrets.yaml` (add secret)
- `sops updatekeys vms/yggi/secrets.yaml` (re-encrypt for new recipients)
- 

* * *

what's missing in sops-nix
---

- run yggdrasil's `genkeys` each time we add a new machine
- manually describe `keys.json`
- manually inject ssh host key (trusted persistent credential)

* * *

what's missing in sops-nix
---

- re-provisioning a configuration is made cheap
- provisioning a new configuration is still expensive

* * *

vars
---

- https://docs.clan.lol/reference/clan-core/vars/
- https://github.com/NixOS/nixpkgs/pull/370444
- an interface for managing the whole cycle from secret generation, to deployment, to its usage in nixos configuration
