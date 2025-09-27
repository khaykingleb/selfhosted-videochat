# selfhosted-videochat

Perfectly fine 👍 If you want to stay with k3s (so it still feels like a mini-cluster and you can deploy via Helm/Ingress), you still don’t need cert-manager for your ephemeral use-case. Instead, you can:
	•	Use Traefik (ships with k3s) as your ingress controller.
	•	Let Traefik handle Let’s Encrypt directly → it has built-in ACME support.
	•	That means no cert-manager, no CRDs, no ClusterIssuer. Just IngressRoutes + Traefik config.

⸻

How it looks with k3s
	1.	Terraform spins up a Droplet (or VM) with cloud-init.
	2.	cloud-init installs k3s (Traefik enabled).
	3.	In /var/lib/rancher/k3s/server/manifests/traefik.yaml (or Helm values override), you configure Traefik with:

additionalArguments:
  - "--certificatesresolvers.le.acme.httpchallenge=true"
  - "--certificatesresolvers.le.acme.httpchallenge.entrypoint=web"
  - "--certificatesresolvers.le.acme.email=you@example.com"
  - "--certificatesresolvers.le.acme.storage=/data/acme.json"

This tells Traefik to request Let’s Encrypt certs automatically.

	4.	Deploy Synapse + Element + coturn via Helm charts, with Ingress objects annotated for Traefik + TLS.
Example (simplified):

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: element
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls.certresolver: le
spec:
  rules:
  - host: element.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: element
            port:
              number: 80
  tls:
  - hosts:
    - element.example.com

Traefik will issue the cert on first request.

⸻

✅ Why this works better for you
	•	Simpler than cert-manager (no CRDs, no ClusterIssuer).
	•	TLS is automatic, even for short-lived clusters.
	•	Destroy/recreate is fine; Traefik just re-requests the cert.
	•	Keeps everything inside k3s → you still deploy via Helm/Ingress like “real infra.”

⸻

⚡️ TL;DR:
If you want k3s but don’t want cert-manager overhead, just let Traefik (bundled with k3s) handle ACME/Let’s Encrypt. You’ll have the same automatic HTTPS, but fewer moving parts.

⸻

Do you want me to sketch out a cloud-init that installs k3s with Traefik ACME enabled + Helm releases (Synapse, Element, coturn), so it’s “apply → wait 2–3 min → call → destroy”?
