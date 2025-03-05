OtaNix: Secret Management
===

`@SomeoneSerge`

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


sops-nix demo
---

- `nvim .sops.yaml` (configure recipients)
- `sops vms/yggi/secrets.yaml` (add secret)
- `sops updatekeys vms/yggi/secrets.yaml` (re-encrypt for new recipients)
- 
