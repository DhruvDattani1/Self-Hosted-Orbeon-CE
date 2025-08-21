
# 🛠️ Self-Hosted Orbeon CE on K3s

This repo is my ongoing project to deploy a **self-hosted Orbeon CE** stack running on **K3s**, with **PostgreSQL** and **MinIO** as backend services. The idea is to have a **secure, modular, production-ready form management system**—all running on Proxmox-provisioned VMs, automated with Ansible, and (eventually) GitOps-managed with ArgoCD.

---

## 📌 Project Premise

* Orbeon CE for form management
* PostgreSQL as the relational database backend
* MinIO for object/file storage
* NGINX + Authelia as reverse proxy & RBAC auth
* Tailscale for secure private access
* Deployed across a K3s cluster (1 master, 3 workers) on Proxmox

Basically, it’s a **full-stack self-hosted Orbeon platform** that supports persistent storage, authentication, and monitoring—without relying on any cloud vendor.

---

## ✅ Current Progress

* VMs provisioned via **Proxmox + Ansible**
* **K3s cluster** (master + workers) up and running
* Namespaces, RBAC, and Traefik ingress controller configured
* Core apps (Orbeon, PostgreSQL, MinIO) deployed into the cluster
* Persistent volumes wired up with shared storage
* Reverse proxy and auth layers stubbed in

---

## ⚠️ Current Roadblock

Right now I’m **stuck on connectivity between Orbeon, PostgreSQL, and MinIO**.

* JDBC configs are being picky (classic `org.postgresql.Driver not found` type of errors, or after I add the driver it still doesnt work lol).
* Orbeon pods spin up fine, but fail at runtime when trying to talk to the DB and storage.
* Likely just driver/classpath config + datasource tuning left to fix.

So everything is **90% there**—the cluster, the services, the automation—just need to untangle these backend connection gremlins. 🐛

---

## 🔑 About the SSH Key in `postinstall.sh`

You might notice an SSH key hardcoded in the **postinstall script**. Don’t worry—it’s an **old, invalid key** left in for convenience/testing.
👉 *No, you can’t hack my cluster with it. But nice try.* 😅

---

## 🚧 Status

This repo is **work in progress**. It already demonstrates:

* VM provisioning with Ansible
* Automated K3s setup
* Helm + raw manifests for app deployments
* Modular project structure with roles for each service

Still on the to-do list:

* Fix JDBC connectivity (Orbeon ↔ Postgres)
* Proper MinIO integration (bucket auto-creation)
* Authelia + reverse proxy integration
* Grafana + Prometheus for metrics/logging
* ArgoCD GitOps workflow

---

## 🗺️ Roadmap

1. **Connectivity Fixes** → stabilize Orbeon ↔ DB ↔ MinIO
2. **Secrets Management** → Vault or K8s secrets
3. **Reverse Proxy & Auth** → NGINX + Authelia
4. **Monitoring & Observability** → Grafana, Prometheus, Loki
5. **GitOps** → ArgoCD with App-of-Apps
6. **Docs & Walkthrough** → full publishing

---

### ⚡ TL;DR

Everything’s deployed and running on K3s, I just need to get Orbeon to stop complaining about JDBC—and then plug in auth, monitoring, and GitOps.

---

