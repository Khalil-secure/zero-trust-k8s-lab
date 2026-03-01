# ADR-003: Istio over Linkerd and Cilium for Service Mesh

**Date:** 2025-11  
**Status:** Accepted  
**Project:** Zero Trust K8s Lab

---

## Context

Zero Trust requires mutual TLS between all services — every service must authenticate with a certificate before communicating. A service mesh handles certificate issuance, rotation, and enforcement automatically without changing application code.

---

## Decision

Use **Istio** with the minimal install profile and STRICT mTLS mode.

---

## Alternatives Considered

### No service mesh (manual TLS)
- ✅ No overhead
- ❌ Each service must manage its own certificates
- ❌ Certificate rotation requires application changes
- ❌ No traffic observability

### Linkerd
- ✅ Lighter weight than Istio (~200MB vs ~1GB)
- ✅ Simpler to operate
- ❌ Less feature-rich — no traffic management, limited AuthorizationPolicies
- ❌ Smaller enterprise adoption than Istio
- ❌ Rust-based data plane — less documentation for troubleshooting

### Cilium (eBPF-based)
- ✅ Kernel-level performance — no sidecar overhead
- ✅ Replaces both NetworkPolicies and service mesh
- ❌ Requires specific kernel versions (5.10+)
- ❌ More complex to configure
- ❌ Steeper learning curve for demonstrating Zero Trust concepts clearly

### Istio ✅ Chosen
- ✅ Industry standard — used by Google, Lyft, IBM in production
- ✅ Most comprehensive AuthorizationPolicy support
- ✅ Kiali dashboard provides visual mesh observability
- ✅ STRICT mTLS mode rejects all plaintext traffic — hard enforcement
- ✅ Sidecar injection is automatic with namespace label
- ✅ Best documentation and community support
- ❌ High memory footprint (~1GB for control plane)
- ❌ Complex internals — steep learning curve
- ❌ Sidecar model adds latency (mitigated with ambient mode in future)

---

## Configuration Choices

**Minimal profile** — installs only istiod (control plane) and no ingress gateway by default. Reduces memory footprint while keeping all security features.

**STRICT mode** (not PERMISSIVE) — PERMISSIVE allows plaintext as fallback, defeating the purpose of Zero Trust. STRICT rejects any connection without a valid certificate.

---

## Consequences

**Positive:**
- Zero Trust enforcement at the service identity layer — even if NetworkPolicies are bypassed, mTLS prevents unauthorized communication
- Certificate rotation handled automatically by Istio — no manual certificate management
- Kiali provides real-time visualization of service-to-service communication

**Negative:**
- Each pod gets an Envoy sidecar container — doubles container count
- ~1GB RAM for Istio control plane — significant on free tier
- Debugging mTLS issues requires understanding Envoy proxy internals
