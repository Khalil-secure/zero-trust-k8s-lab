# ADR-001: k3s over Full Kubernetes Distribution

**Date:** 2025-11  
**Status:** Accepted  
**Project:** Zero Trust K8s Lab

---

## Context

The Zero Trust lab requires a Kubernetes cluster to demonstrate namespace segmentation, NetworkPolicies, and Istio service mesh. The cluster needs to run on Oracle Cloud Free Tier (4 ARM vCPUs, 24GB RAM total across instances).

---

## Decision

Use **k3s** — a lightweight, CNCF-certified Kubernetes distribution by Rancher.

---

## Alternatives Considered

### kubeadm (vanilla Kubernetes)
- ✅ Official Kubernetes tooling
- ✅ Maximum compatibility
- ❌ High memory footprint (~2GB just for control plane)
- ❌ Complex setup — etcd, control-plane components, networking all separate
- ❌ Leaves insufficient RAM for Istio + workloads on free tier

### minikube
- ✅ Simple local development
- ❌ Designed for local dev, not cloud deployment
- ❌ Single-node only
- ❌ Not representative of production environments

### Kind (Kubernetes in Docker)
- ✅ Fast, reproducible
- ❌ Runs inside Docker — adds layer of abstraction
- ❌ Not suitable for production-like network testing
- ❌ NetworkPolicies behave differently inside Docker network

### k3s ✅ Chosen
- ✅ CNCF certified — 100% Kubernetes API compatible
- ✅ ~512MB RAM footprint vs ~2GB for kubeadm
- ✅ Single binary install: `curl -sfL https://get.k3s.io | sh`
- ✅ Used in production by enterprises for edge computing
- ✅ Leaves enough RAM for Istio (1GB+) and workloads
- ✅ Supports all features we need: NetworkPolicies, RBAC, Ingress
- ❌ Some enterprise features (etcd HA) require additional config

---

## Consequences

**Positive:**
- Entire cluster fits in Oracle Cloud free tier permanently
- Same Kubernetes API — manifests are portable to any K8s distribution
- Fast cluster setup (~2 minutes vs ~15 for kubeadm)

**Negative:**
- Uses SQLite by default instead of etcd (acceptable for lab environment)
- Some enterprise HA patterns require additional configuration
