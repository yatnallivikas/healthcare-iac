# Platform Architecture

This repository models a simple yet production-ready path for exposing microservices deployed on EKS. Below is a high-level, text-based flow to visualize the traffic path and observability fan-out.

```
Internet
  ↓
ALB
  ↓
Ingress
  ↓
Service
  ↓
Pods
  ↓
CloudWatch / Prometheus
```

## Design Notes

- Application Load Balancers (public or internal) terminate TLS and forward requests to the Kubernetes ingress layer.
- NGINX ingress rules route traffic to ClusterIP services, which in turn target application pods on port 8080.
- Pods emit metrics to Prometheus (optional) and logs/metrics to CloudWatch for centralized operations.
- Future enhancements may add service mesh, WAF, and CDN integrations without altering this foundational flow.
