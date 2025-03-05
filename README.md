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

Generate secrets in advance, and encrypt them
