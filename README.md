OtaNix: Secret Management
===

`@SomeoneSerge`

![](./qr.png)

_Structure inspired by @lassulus' and @a-kenji's Planet Nix talk_

* * *

NixOS
---

- Declarative:
    - static configuration,
    - atomic switch.
- Secrets (by example)
    - `users.users.<name>.password`: git and `/nix/store` are world-readable
    - `passwordFile`: secrets are state
        - Brings back the state's complexity
    - `services.openssh.hostKeys`: auto-generate secrets
        - easier to provision
        - public keys only available after switch
        - backups, re-provisioning are manual

* * *

agenix, sops-nix
---

- Pre-generate, encrypt, and version-control the secrets
- Stateless except for decryption key
- Provisioning more machines is manual

* * *

sops-nix demo
---

- `nix run -f . vms.yggi`
- `nvim .sops.yaml` (configure recipients)
    - developer's keys (cf. e.g.)
    - target machine's ssh host keys
- `sops vms/yggi/secrets.yaml` (add secret)
- `sops updatekeys vms/yggi/secrets.yaml` (re-encrypt for new recipients)
- 

* * *

horizontal scaling is manual
---

- run yggdrasil's `genkeys` each time we add a new machine
- manually describe `keys.json`
- manually inject ssh host key (trusted persistent credential)

* * *

nixos not designed for injecting secrets
---

- `services.yggdrasil.persistentKeys`
    - enables auto-generation,
    - and mutable state,
    - and is ad hoc.
- `serviceConfig.DynamicUser` and ownership issues.

* * *

vars[^1][^2]
---

- standardization effort
- declarative description
  - generate secrets;
  - derive public parts, use at evaluation time;
  - access decrypted keys at OS' run-time;
  - composable and reusable;
  - accommodates horizontal scalability.
- systemic solution:
  - develop a standard,
  - refactor nixos modules,
  - maintain consistent secret management story.


[^1]: https://docs.clan.lol/reference/clan-core/vars/
[^2]: https://github.com/NixOS/nixpkgs/pull/370444
