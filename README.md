# Puppet Homelab Configuration Management

> Declarative Linux configuration-management project using Puppet to define, preview, apply, and verify system state in an Ubuntu homelab.

---

## Project Overview

This repository demonstrates a foundational Puppet workflow for managing Linux systems declaratively.

Instead of manually configuring each system, Puppet resources describe the desired state. Puppet compares that declaration with the current system and applies only the required changes.

The project currently demonstrates:

- Puppet environment organization
- Reusable Puppet module structure
- Node classification through a production manifest
- Puppet manifest syntax validation
- Package management
- File management
- No-change previews with `--noop`
- Local catalog application
- Configuration-drift correction
- Idempotent configuration enforcement
- Git-based version control

---

## Current Architecture

```text
+-----------------------------+
| Ubuntu Terraform Controller |
| tf-controller               |
+--------------+--------------+
               |
               | puppet apply
               | --modulepath=modules
               v
+-----------------------------+
| Production Manifest         |
| site.pp                     |
| include common              |
+--------------+--------------+
               |
               v
+-----------------------------+
| Reusable common Module      |
| modules/common/manifests/   |
| init.pp                     |
+--------------+--------------+
               |
               v
+-----------------------------+
| Locally Managed Resources   |
| - htop package              |
| - managed test file         |
+-----------------------------+
```

The current version uses local `puppet apply` execution and a reusable `common` module.

A future milestone will introduce a dedicated Puppet Server and managed Puppet Agent nodes.

---

## Technologies

| Technology | Purpose |
|---|---|
| Puppet Agent 8.4.0 | Declarative configuration management |
| Puppet DSL | Resource and catalog definitions |
| Ubuntu Server 24.04 LTS | Development and test platform |
| Git | Source control and release management |
| Bash | Command-line project operation |

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
├── modules/
│   └── common/
│       └── manifests/
│           └── init.pp
├── scripts/
├── .gitignore
├── environment.conf
├── LICENSE
├── Puppetfile
└── README.md
```

---

## Production Environment

The Puppet environment configuration is stored in:

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

The production manifest classifies the default node by including the reusable `common` class:

```puppet
node default {
  include common
}
```

---

## Reusable Common Module

The reusable module is defined in:

```text
modules/common/manifests/init.pp
```

Its class declaration is:

```puppet
class common {
  package { 'htop':
    ensure => installed,
  }

  file { '/tmp/puppet-managed.txt':
    ensure  => file,
    content => "Managed by Puppet\n",
    mode    => '0644',
  }
}
```

Moving these resources into a class separates node classification from resource implementation.

The production manifest determines which class is assigned, while the module contains the resources that Puppet manages.

---

## Managed Resources

The `common` module currently manages two resources.

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

- File existence
- File content
- File permissions
- Root ownership through privileged execution

---

## Validate Puppet Syntax

Validate both the reusable module and the production manifest:

```bash
puppet parser validate \
  modules/common/manifests/init.pp \
  environments/production/manifests/site.pp
```

A successful validation produces no output and returns exit code `0`.

Check the exit code with:

```bash
echo $?
```

Expected result:

```text
0
```

---

## Preview Changes

Use Puppet no-change mode to inspect what Puppet would modify:

```bash
sudo puppet apply \
  --noop \
  --modulepath="$(pwd)/modules" \
  environments/production/manifests/site.pp
```

The `--modulepath` option tells Puppet where to locate the local `common` module.

The `--noop` option compiles the catalog and reports required changes without modifying the system.

Example drift detection:

```text
File[/tmp/puppet-managed.txt]/ensure:
current_value 'absent', should be 'file' (noop)
```

---

## Apply the Manifest

Apply the declared configuration:

```bash
sudo puppet apply \
  --modulepath="$(pwd)/modules" \
  environments/production/manifests/site.pp
```

Verify the managed file:

```bash
ls -l /tmp/puppet-managed.txt
cat /tmp/puppet-managed.txt
```

Expected permissions and ownership:

```text
-rw-r--r-- 1 root root
```

Expected content:

```text
Managed by Puppet
```

---

## Configuration-Drift Testing

The managed file can be removed manually to simulate configuration drift:

```bash
sudo rm /tmp/puppet-managed.txt
```

Preview Puppet’s corrective action:

```bash
sudo puppet apply \
  --noop \
  --modulepath="$(pwd)/modules" \
  environments/production/manifests/site.pp
```

Apply the catalog to restore the declared state:

```bash
sudo puppet apply \
  --modulepath="$(pwd)/modules" \
  environments/production/manifests/site.pp
```

Puppet recreates the file with its declared content and permissions.

---

## Idempotency

Run the same manifest again:

```bash
sudo puppet apply \
  --modulepath="$(pwd)/modules" \
  environments/production/manifests/site.pp
```

When the system already matches the declared state, Puppet completes without reporting resource changes.

This demonstrates idempotency: repeated execution maintains the same desired configuration without unnecessary modifications.

---

## Development Workflow

The current workflow is:

```text
Write or update module
          |
          v
Assign module in site.pp
          |
          v
Validate Puppet syntax
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
Simulate configuration drift
          |
          v
Allow Puppet to restore state
          |
          v
Apply again to confirm idempotency
```

---

## Puppetfile

The repository contains a minimal `Puppetfile`:

```ruby
forge "https://forge.puppet.com"
```

This establishes the Puppet Forge source for future external module dependencies.

The current `common` module is maintained locally and does not require a Forge dependency.

---

## Version History

| Version | Description |
|---|---|
| v0.1.0 | Initial local Puppet workflow with package and file resource management |
| v0.2.0 | Refactors managed resources into a reusable `common` module |

Version `v0.2.0` remains under development until the feature branch is reviewed, merged, tagged, and published.

---

## Current Status

Completed:

- Puppet Agent 8.4.0 installed on the controller
- Production environment structure created
- Production node classification implemented
- Reusable `common` module created
- Module and manifest syntax validation confirmed
- Package resource tested
- File resource tested
- Local module-path resolution tested
- No-change preview tested
- Local catalog application tested
- Configuration-drift detection tested
- Configuration-drift correction tested
- Idempotency confirmed
- Git repository and v0.1.0 release published

---

## Planned Milestones

Future development may include:

- Dedicated Puppet Server
- Puppet Agent enrollment
- Certificate signing and trust establishment
- Node-specific classification
- Hiera data separation
- Parameterized Puppet classes
- Package, service, user, and SSH configuration classes
- Automated validation scripts
- CI checks for Puppet manifests
- Integration with Terraform-provisioned Ubuntu VMs

Terraform, Ansible, and Puppet remain separate repositories so each tool has a clear responsibility:

- Terraform provisions infrastructure.
- Ansible performs bootstrap and procedural configuration.
- Puppet continuously enforces declared system state.

---

## Learning Objectives

This project demonstrates practical experience with:

- Declarative configuration management
- Puppet manifests
- Puppet classes
- Reusable Puppet modules
- Node classification
- Puppet resources
- Catalog compilation
- Module-path configuration
- Syntax validation
- No-change testing
- Package management
- File management
- Configuration-drift correction
- Idempotency
- Environment organization
- Git branching and versioning

---

## Author

**Edilberto Rodriguez**

Infrastructure Automation • Networking • Cybersecurity • Virtualization

Blue Team Level 1 (BTL1)

Building enterprise-style home lab environments focused on infrastructure automation, systems administration, cybersecurity, and configuration management.

---

## License

This project is licensed under the MIT License. See `LICENSE` for details.
