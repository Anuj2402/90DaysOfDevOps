# Task 1: Recall the Kubernetes Story

#### Q1-> Why was Kubernetes created? What problem does it solve that Docker alone cannot?

Docker is excellent for building, packaging, and running containers, but Docker by itself is mainly focused on individual machines. Once you have many **containers across many machines**, you need something to handle:

- deploying multiple instances
- scheduling containers across machines
- service discovery and load balancing
- health checks and self-healing
- scaling
- rollouts and rollbacks

Kubernetes was created to solve that **large-scale container management problem**. Google's Kubernetes team explicitly described Docker as great for individual containers/machines, but not the complete solution for managing large numbers of containers across a fleet.

The official Kubernetes docs describe it as a platform for managing containerized workloads and services, with automation, scaling, failover, service discovery, load balancing, rollouts/rollbacks, and self-healing.

Interview answer:

- Docker helps us build and run containers, but when we have hundreds or thousands of containers distributed across multiple machines, we need a system to schedule, scale, monitor, heal, and expose those containers. Kubernetes provides that platform.

#### Q2-> Who created Kubernetes and what was it inspired by?

Kubernetes originated at **Google.**

It was strongly inspired by Google's internal Borg system, which Google had used for running containerized workloads at large scale. Kubernetes also incorporated ideas from Google's later **Omega** project.

The initial Kubernetes team included Joe Beda, Brendan Burns, Craig McLuckie, and others including Ville Aikas, Tim Hockin, Dawn Chen, Brian Grant, and Daniel Smith.

Kubernetes was open-sourced by Google in 2014
**Google → Borg/Omega experience → Kubernetes → open sourced in 2014**

#### Q3-> What does "Kubernetes" mean?
This one is straightforward:
**Kubernetes comes from Greek and means "helmsman" or "pilot."**

A **helmsman** is the person who steers a ship.

That's actually a nice way to remember the concept:
```
Containers = the workload
Kubernetes = the helmsman
Cluster = the ship
```
Kubernetes continuously works to move the cluster toward the desired state you declare

And K8s?
```
K + 8 letters + s
Kubernetes
   ↓
K  u b e r n e t e  s
   \____8 letters____/
 ```
Hence K8s.

our final memory version
**Docker → containers → scale problem → Kubernetes → Google → Borg/Omega → orchestration, scaling, self-healing → "helmsman"**

