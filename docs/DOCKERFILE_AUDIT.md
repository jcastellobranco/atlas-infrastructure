# Dockerfile audit — ATLAS services

Reviewed the Dockerfiles in the five sibling repositories. This is a source-level review; no image build or container runtime tests were performed.

| Repository | Dockerfile | Multi-stage | Runtime user | Notes |
|---|---|---|---|---|
| ai-inference-platform | frontend/Dockerfile | **Yes** | Nginx image default | Node 22 Alpine builds, Nginx 1.27 Alpine serves; `npm install` should become `npm ci` with a committed lockfile. |
| ai-inference-platform | backend/Dockerfile | **No** | UID 10001 | Python 3.12 slim, installs requirements in the final image. |
| rag-document-intelligence | Dockerfile | **No** | UID 10001 | Python 3.12 slim, optional PDF dependencies. |
| rag-document-intelligence | Dockerfile.vector | **No** | UID 10001 | This is the Dockerfile actually used by the integrated Compose; vector, embedding and PDF extras may enlarge the image. |
| llm-evaluation-observability | Dockerfile | **No** | UID 10001 | Python 3.12 slim, single stage. |
| multi-agent-orchestration | Dockerfile.agent-demo | **No** | UID 65534 | Python 3.11 slim, installs MCP extras in the final image. |
| mcp-tool-platform | root Dockerfile | **Absent** | n/a | Runs as a subprocess from Multi-Agent, mounted as a read-only sibling checkout in local Compose; not currently an independently containerized service. |

## Recommendations

1. Keep frontend build/runtime separation; use `npm ci`, consider pinned digest versions and a non-root Nginx runtime where compatible.
2. Convert Python services to two stages when build-only dependencies are needed: wheel/dependency builder followed by slim runtime, preserving non-root UID and reproducible dependency locks. A single-stage Python slim image can be reasonable if no build toolchain remains in it; multi-stage is not mandatory.
3. Make the agent image self-contained by packaging the MCP tool platform into the image instead of mounting a sibling source tree. This is necessary for an ECS image-based deployment.
4. Add `.dockerignore`, image scanning, SBOM, pinned base images and build checks in CI.
5. Correct the ECS reference infrastructure's frontend container port: the current Nginx Dockerfile listens on **80**, while the Terraform ECS module currently expects **3000**. Also supply real application environment variables and secrets before any deployment.
6. The ECS/RDS infrastructure remains a **reference scaffold**, not production ready. The independent EC2 demo profile does not make these services production ready.

No Dockerfiles were modified in this audit.
