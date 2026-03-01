# Zero Trust Network Lab 🛡️
### Kubernetes & Infrastructure-as-Code

> A production-grade Zero Trust architecture on Kubernetes — namespace micro-segmentation, mTLS via Istio, OPA policy enforcement, WireGuard VPN, and automated security scanning via CI/CD.

![CI](https://github.com/Khalil-secure/zero-trust-k8s-lab/actions/workflows/ci.yml/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform-1.6-purple?logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-k3s-blue?logo=kubernetes)
![Istio](https://img.shields.io/badge/Istio-1.20-orange?logo=istio)
![Oracle Cloud](https://img.shields.io/badge/Oracle_Cloud-Free_Tier-red?logo=oracle)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📌 Project Vision

This project extends the [hardened-infra](https://github.com/Khalil-secure/hardened-infra) lab into a full Zero Trust Kubernetes environment. Where the previous project hardened a single server, this one enforces Zero Trust across an entire distributed infrastructure — every service must authenticate, every connection is encrypted, every policy is enforced by code.

**Zero Trust principle:** Never trust, always verify — regardless of whether traffic is internal or external.

---

## Roadmap

- [x] **Phase 1** — Terraform IaC: Oracle Cloud VM provisioning, VCN, security lists
- [x] **Phase 2** — k3s cluster: namespace segmentation, deny-all NetworkPolicies
- [x] **Phase 3** — OPA/Gatekeeper: policy-as-code constraints, Trivy CI scanning
- [x] **Phase 4** — Istio Service Mesh: mTLS STRICT mode, AuthorizationPolicies
- [x] **Phase 5** — WireGuard VPN: encrypted site-to-site tunnel template
- [x] **Phase 6** — CI/CD pipeline: automated validation, Trivy IaC scan, MITRE ATT&CK report
- [ ] **Phase 7** — Suricata IDS + Grafana SOC dashboard (in progress)
- [ ] **Phase 8** — MITRE ATT&CK live simulations (T1021, T1046, T1190)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Oracle Cloud (Free Tier — 24GB RAM)              │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   k3s Cluster                                │   │
│  │                                                              │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐            │   │
│  │  │ ns:frontend │  │ ns:backend │  │ ns:database│            │   │
│  │  │ NetworkPol  │  │ NetworkPol │  │ NetworkPol │            │   │
│  │  │ mTLS:STRICT │  │ mTLS:STRICT│  │ mTLS:STRICT│           │   │
│  │  └────────────┘  └────────────┘  └────────────┘            │   │
│  │                                                              │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐            │   │
│  │  │ns:monitoring│  │ns:security │  │ns:istio-sys│            │   │
│  │  │Loki/Grafana │  │OPA/Falco   │  │Envoy proxy │            │   │
│  │  └────────────┘  └────────────┘  └────────────┘            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                    WireGuard VPN (:51820/udp)                        │
└──────────────────────────────┼──────────────────────────────────────┘
                               │
                    Local dev machine
                    (Terraform + kubectl)
```

---

## Network Segmentation

Default policy: **DENY ALL ingress + egress**

```
Explicit allow rules:
  internet  → frontend   (port 443 only via ingress)
  frontend  → backend    (port 8080 only)
  backend   → database   (port 5432 only)
  monitoring → ALL       (port 9090 metrics scraping)
  
  Everything else: DROPPED ✗
```

---

## CI/CD Pipeline

Every push triggers 5 automated jobs:

```
┌─────────────────────────────────────────────────────┐
│  Push to main                                        │
│         │                                            │
│    ┌────┴────┐                                       │
│    ▼         ▼         ▼          ▼                  │
│  Kubeval  Trivy    Terraform   YAML lint             │
│  K8s      IaC      validate                          │
│  schemas  scan                                       │
│    └────┬─────┘                                      │
│         ▼                                            │
│   MITRE ATT&CK Security Posture Report               │
└─────────────────────────────────────────────────────┘
```

**Trivy IaC scan** checks all Terraform and Kubernetes files for misconfigurations — open security groups, missing resource limits, privileged containers, etc.

**MITRE ATT&CK report** is generated on every build and uploaded as a GitHub Actions artifact.

---

## MITRE ATT&CK Coverage

| Technique | ID | Control |
|---|---|---|
| Remote Services | T1021 | NetworkPolicies + mTLS |
| Network Service Discovery | T1046 | Deny-all egress policies |
| Exploit Public-Facing App | T1190 | WAF + Istio AuthorizationPolicy |
| Container Escape | T1611 | OPA deny-privileged constraint |
| Lateral Movement | T1021.004 | Namespace micro-segmentation |
| Privilege Escalation | T1068 | OPA deny-privileged + resource limits |

---

## Repository Structure

```
zero-trust-k8s-lab/
├── .github/
│   └── workflows/
│       └── ci.yml              # Trivy + kubeval + terraform validate
├── terraform/
│   ├── main.tf                 # Oracle Cloud VM + VCN + security lists
│   ├── variables.tf            # All variables with descriptions
│   ├── terraform.tfvars.example
│   └── scripts/
│       ├── install-k3s-master.sh
│       └── install-k3s-worker.sh
├── k8s/
│   ├── namespaces/
│   │   └── namespaces.yaml     # 5 namespaces with Istio injection labels
│   ├── network-policies/
│   │   └── network-policies.yaml  # Deny-all + explicit allow rules
│   └── istio/
│       └── mtls-policies.yaml  # PeerAuthentication + AuthorizationPolicy
├── opa/
│   └── policies/
│       └── constraints.yaml    # No-privileged, required-labels, allowed-registries
├── wireguard/
│   └── wg0.conf.template       # Site-to-site VPN config
└── docs/
    └── architecture.md
```

---

## Deployment

### Prerequisites
- Terraform >= 1.3
- Oracle Cloud account (free tier works)
- SSH key pair
- OCI API key

### 1. Clone
```bash
git clone https://github.com/Khalil-secure/zero-trust-k8s-lab.git
cd zero-trust-k8s-lab
```

### 2. Configure
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Fill in your Oracle Cloud OCIDs and key paths
```

### 3. Deploy infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
# Cluster ready in ~5 minutes
```

### 4. Apply Zero Trust policies
```bash
export KUBECONFIG=~/kubeconfig

# Namespaces
kubectl apply -f k8s/namespaces/

# Network policies — deny-all baseline
kubectl apply -f k8s/network-policies/

# Istio mTLS
kubectl apply -f k8s/istio/

# OPA Gatekeeper constraints
kubectl apply -f opa/policies/
```

### 5. Verify Zero Trust is enforced
```bash
# This should FAIL — frontend cannot reach database directly
kubectl exec -n frontend deploy/frontend -- curl database.database.svc.cluster.local:5432

# This should SUCCEED — frontend can reach backend
kubectl exec -n frontend deploy/frontend -- curl backend.backend.svc.cluster.local:8080
```

---

## Tech Stack

| Category | Tool | Purpose |
|---|---|---|
| Container orchestration | k3s | Lightweight Kubernetes |
| Service mesh | Istio 1.20 | mTLS + traffic management |
| Policy engine | OPA + Gatekeeper | Admission control |
| Image scanning | Trivy | CVE + misconfiguration detection |
| VPN | WireGuard | Site-to-site encryption |
| IaC | Terraform | Reproducible Oracle Cloud infra |
| Observability | Loki + Grafana + Kiali | Logs + metrics + mesh visualization |
| CI/CD | GitHub Actions | Automated security validation |
| Cloud | Oracle Cloud Free Tier | 4 vCPU + 24GB RAM — permanent free |

---

## Why Oracle Cloud Free Tier?

| | Oracle | AWS | Azure |
|---|---|---|---|
| RAM | **24GB** | 1GB | 1GB |
| vCPUs | **4 ARM** | 1 | 1 |
| Duration | **Permanent** | 12 months | 12 months |
| Istio + k3s | ✅ Comfortable | ❌ Too tight | ❌ Too tight |

---

## Author

**Khalil Ghiati** — Infrastructure & Security Engineer

[![GitHub](https://img.shields.io/badge/GitHub-Khalil--secure-181717?logo=github)](https://github.com/Khalil-secure)
[![Portfolio](https://img.shields.io/badge/Portfolio-khalilghiati.dev-0F4C81)](https://portfolio-khalil-secure.vercel.app)

[![hardened-infra](https://img.shields.io/badge/Previous_Project-hardened--infra-0F4C81)](https://github.com/Khalil-secure/hardened-infra)
