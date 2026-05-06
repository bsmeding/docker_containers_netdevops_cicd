# NetDevOps CI/CD Docker Images

Prebuilt Docker images for NetDevOps CI/CD pipelines that need network automation, validation, linting, and API tooling without making Ansible the default runtime.

These images are intended for pipelines that render configs, test network intent, validate API integrations, run Nornir/Scrapli/Netmiko jobs, and exercise Nautobot/NetBox workflows.

## Supported Base Images

Each image is built for a specific OS to match production environments or CI runner needs:

- `ubuntu2404` -> Ubuntu 24.04
- `ubuntu2604` -> Ubuntu 26.04
- `debian12` -> Debian Bookworm
- `debian13` -> Debian Trixie
- `rockylinux8` -> Rocky Linux 8
- `rockylinux9` -> Rocky Linux 9
- `alpine3.22` -> Alpine 3.22
- `alpine3.23` -> Alpine 3.23

Only the latest two versions per distro family are actively built and maintained. Older Docker Hub images remain available but are no longer updated.

Default tags point to the newest supported version for each distro family:

- `ubuntu` -> Ubuntu 26.04
- `debian` -> Debian Trixie
- `rockylinux` -> Rocky Linux 9
- `alpine3` -> Alpine 3.23

Each image is tagged as:

```text
bsmeding/netdevops_cicd_<tag>:latest
```

## Included Software

Each image includes:

- Python 3 with a virtual environment at `/opt/venv`
- Network automation libraries: Netmiko, Scrapli, Nornir, NAPALM, ncclient, Paramiko
- Source-of-truth clients: pynautobot and pynetbox
- Config and data tooling: Jinja2, YAML, JSON Schema, JMESPath, TTP, TextFSM, ntc-templates, jc, jtbl, OpenPyXL, SQLModel
- Network parsing and platform helpers: asyncssh, dnacentersdk, netutils
- CI tooling: pytest, pytest-cov, pytest-xdist, ruff, mypy, yamllint
- API tooling: requests, httpx, rich, typer
- Common shell utilities: git, curl, jq, SSH client, sshpass, rsync, DNS tools, nmap, tcpdump, traceroute, unzip, sqlite

Ansible is intentionally not included. Use the `ansible_cicd` images when you need Molecule or Ansible role testing.

## Use Cases

- Test Python-based NetDevOps automation
- Validate generated configs and structured output
- Run Nornir/Scrapli/Netmiko jobs in CI
- Test Nautobot/NetBox sync jobs
- Run linting and unit tests for network automation repositories
- Build lightweight CI jobs where Ansible is unnecessary

## GitHub Actions Example

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: bsmeding/netdevops_cicd_ubuntu:latest
    steps:
      - uses: actions/checkout@v5
      - run: pytest
      - run: ruff check .
```

## Notes

pyATS/Genie is useful for some network validation workflows, but it is not installed by default because its package support can be platform-specific and less reliable across Alpine and multi-arch builds. Add it in pipeline-specific images when needed.

Third-party software installed in the image retains its own license terms.

## License

Apache-2.0

## Maintainer

[bsmeding](https://github.com/bsmeding) - Built for reproducible NetDevOps pipelines.
