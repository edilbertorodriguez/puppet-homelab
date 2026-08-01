# Puppet Homelab Configuration Management

> Declarative Linux configuration-management project using Puppet to define, preview, apply, and verify system state in an Ubuntu homelab.

---

## Project Overview

This repository demonstrates the foundational Puppet workflow used to manage Linux systems declaratively.

Instead of manually configuring each system, Puppet resources describe the desired state. Puppet then compares that declaration with the current system and applies only the required changes.

The initial v0.1.0 milestone demonstrates:

* Puppet environment organization
* Puppet manifest syntax validation
* Package management
* File management
* No-change previews with `--noop`
* Local catalog application
* Idempotent configuration enforcement
* Git-based version control

---

## Current Architecture

```text
+----------------------------+
| Ubuntu Terraform Controller|
| tf-controller              |
+-------------+--------------+
              |
              | puppet apply
              v
+----------------------------+
| Production Puppet Manifest |
| site.pp                    |
+-------------+--------------+
              |
              v
+----------------------------+
| Locally Managed Resources  |
| - htop package             |
| - managed test file        |
+----------------------------+
```

The current version uses local `puppet apply` execution.

A future milestone will introduce a dedicated Puppet Server and managed Puppet Agent nodes.

---

## Technologies

| Technology              | Purpose                               |
| ----------------------- | ------------------------------------- |
| Puppet Agent 8.4.0      | Declarative configuration management  |
| Puppet DSL              | Resource and catalog definitions      |
| Ubuntu Server 24.04 LTS | Development and test platform         |
| Git                     | Source control and release management |
| Bash                    | Command-line project operation        |

---

## Repository Structure

```text
puppet-homelab/
├── docs/
├── environments/
│   └── production/
│       ├── manifests/
│       │   └── site.pp
│       └── modules/
├── manifests/
│   └── site.pp
├── modules/
├── scripts/
├── .gitignore
├── environment.conf
├── LICENSE
├── Puppetfile
└── README.md
```

---

## Production Environment

The production environment is configured through:

```text
environment.conf
```

Current configuration:

```ini
modulepath = modules:$basemodulepath
manifest = manifests
```

The primary production manifest is:

```text
environments/production/manifests/site.pp
```

---

## Managed Resources

The initial manifest manages two resources.

### Package Resource

Puppet ensures that `htop` is installed:

```puppet
package { 'htop':
  ensure => installed,
}
```

### File Resource

Puppet creates and maintains a test file:

```puppet
file { '/tmp/puppet-managed.txt':
  ensure  => file,
  content => "Managed by Puppet\n",
  mode    => '0644',
}
```

Puppet enforces:

* File existence
* File content
* File permissions
* Root ownership through privileged execution

---

## Validate Manifest Syntax

Validate the production manifest before applying it:

```bash
puppet parser validate \
  environments/production/manifests/site.pp
```

A successful validation produces no output and returns exit code `0`.

Check the exit code with:

```bash
echo $?
```

---

## Preview Changes

Use Puppet no-change mode to inspect what Puppet would modify:

```bash
sudo puppet apply \
  --noop \
  environments/production/manifests/site.pp
```

The `--noop` option compiles the catalog and reports required changes without modifying the system.

Example:

```text
File[/tmp/puppet-managed.txt]/ensure:
current_value 'absent', should be 'file' (noop)
```

---

## Apply the Manifest

Apply the declared configuration:

```bash
sudo puppet apply \
  environments/production/manifests/site.pp
```

Verify the managed file:

```bash
ls -l /tmp/puppet-managed.txt
cat /tmp/puppet-managed.txt
```

Expected content:

```text
Managed by Puppet
```

---

## Idempotency

Run the same manifest again:

```bash
sudo puppet apply \
  environments/production/manifests/site.pp
```

When the system already matches the declared state, Puppet completes without reporting resource changes.

This demonstrates idempotency: repeated execution produces the same desired configuration without unnecessary modifications.

---

## Development Workflow

The initial workflow is:

```text
Write manifest
      |
      v
Validate syntax
      |
      v
Preview with --noop
      |
      v
Apply catalog
      |
      v
Verify managed state
      |
      v
Apply again to confirm idempotency
```

---

## Version History

| Version | Description                                                             |
| ------- | ----------------------------------------------------------------------- |
| v0.1.0  | Initial local Puppet manifest workflow with package and file management |

---

## Current Status

Completed:

* Puppet Agent 8.4.0 installed on the controller
* Production environment structure created
* Manifest syntax validation confirmed
* Package resource tested
* File resource tested
* No-change preview tested
* Local catalog application tested
* Idempotency confirmed
* Initial Git repository and tag created

---

## Planned Milestones

Future development may include:

* Reusable Puppet modules
* Dedicated Puppet Server
* Puppet Agent enrollment
* Certificate signing and trust establishment
* Node-specific classification
* Hiera data separation
* Package, service, user, and SSH configuration classes
* Automated validation scripts
* CI checks for Puppet manifests
* Integration with Terraform-provisioned Ubuntu VMs

Terraform, Ansible, and Puppet remain separate repositories so each tool has a clear responsibility:

* Terraform provisions infrastructure.
* Ansible performs bootstrap and procedural configuration.
* Puppet continuously enforces declared system state.

---

## Learning Objectives

This project demonstrates practical experience with:

* Declarative configuration management
* Puppet manifests
* Puppet resources
* Catalog compilation
* Syntax validation
* No-change testing
* Package management
* File management
* Idempotency
* Environment organization
* Git versioning

---

## Author

**Edilberto Rodriguez**

Infrastructure Automation • Networking • Cybersecurity • Virtualization

Blue Team Level 1 (BTL1)

Building enterprise-style home lab environments focused on infrastructure automation, systems administration, cybersecurity, and configuration management.

---

## License

This project is intended for educational and portfolio purposes. See `LICENSE` for details.
