# ADR-002: Oracle Cloud Free Tier over AWS/Azure/GCP

**Date:** 2025-11  
**Status:** Accepted  
**Project:** Zero Trust K8s Lab

---

## Context

The Zero Trust lab needs a cloud environment to demonstrate real infrastructure provisioning. The cluster must be permanently available (not expire after 12 months) and have enough resources to run k3s + Istio + monitoring stack simultaneously.

---

## Decision

Use **Oracle Cloud Free Tier** (Always Free) with ARM-based VM.Standard.A1.Flex instances.

---

## Alternatives Considered

### AWS Free Tier (t2.micro)
- 1 vCPU, 1GB RAM
- 12 months only
- ❌ Completely insufficient for k3s + Istio (needs 4GB+ RAM minimum)
- ❌ Expires — lab stops working after a year

### Azure Free Tier (B1s)
- 1 vCPU, 1GB RAM
- 12 months only
- ❌ Same problem as AWS — insufficient resources and expires

### GCP Free Tier (e2-micro)
- 0.25 vCPU, 1GB RAM
- Permanent but extremely limited
- ❌ Cannot run Kubernetes at all

### DigitalOcean / Hetzner (paid)
- ✅ Good value, reliable
- ❌ Costs ~$5-20/month
- ❌ Not free — adds ongoing cost to a lab project

### Oracle Cloud Free Tier ✅ Chosen
- ✅ **4 ARM vCPUs + 24GB RAM total — permanent, never expires**
- ✅ Sufficient for: k3s master (2 vCPU/12GB) + worker (1 vCPU/6GB) + monitoring
- ✅ ARM instances run standard ARM64 Linux containers without modification
- ✅ Terraform OCI provider is mature and well-documented
- ✅ Demonstrates cloud-agnostic IaC skills (not just AWS)
- ❌ ARM architecture — some container images need multi-arch builds
- ❌ Less brand recognition than AWS/Azure in job descriptions
- ❌ Oracle Cloud UI is less intuitive than AWS Console

---

## Resource Allocation

| Instance | Shape | vCPUs | RAM | Role |
|---|---|---|---|---|
| k3s-master | A1.Flex | 2 | 12GB | Control plane + Istio |
| k3s-worker | A1.Flex | 1 | 6GB | Workloads + monitoring |

Total: 3 vCPU, 18GB RAM — well within the 4 vCPU / 24GB free allocation.

---

## Consequences

**Positive:**
- Zero ongoing cost — lab stays live permanently
- Enough resources to run a realistic multi-service architecture
- Demonstrates Terraform skills on a non-AWS provider

**Negative:**
- Must ensure Docker images support linux/arm64
- Oracle Cloud support is slower than AWS/Azure
