# mek-code Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Host (M2 Mac)                     │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │            mek-code-network (bridge)                │   │
│  │                                                     │   │
│  │  ┌─────────────────┐      ┌──────────────────┐    │   │
│  │  │  model          │      │  agent           │    │   │
│  │  │  Container      │      │  Container       │    │   │
│  │  │                 │      │                  │    │   │
│  │  │  ollama/ollama  │◄────►│  OpenCode CLI    │    │   │
│  │  │  :latest        │      │  (Python 3.11)   │    │   │
│  │  │                 │      │                  │    │   │
│  │  │  Model:         │      │  API Base:       │    │   │
│  │  │  qwen3:4b-16k   │      │  http://model:   │    │   │
│  │  │                 │      │  11434           │    │   │
│  │  │  Port: 11434    │      │                  │    │   │
│  │  └─────────────────┘      └──────────────────┘    │   │
│  │         │                          │              │   │
│  └─────────┼──────────────────────────┼──────────────┘   │
│            │                          │                   │
│            ▼                          ▼                   │
│  ┌─────────────────┐      ┌──────────────────┐          │
│  │  ollama_data    │      │  agent_data      │          │
│  │  Volume         │      │  Volume          │          │
│  │                 │      │                  │          │
│  │  - Models       │      │  - Workspace     │          │
│  │  - Config       │      │  - User data     │          │
│  └─────────────────┘      └──────────────────┘          │
│                                                           │
│  Port Mapping:                                           │
│  Host:11434 → model:11434                                │
│                                                           │
└───────────────────────────────────────────────────────────┘

Data Flow:
1. User interacts with agent container
2. Agent sends requests to model container via internal network
3. Model processes requests using qwen3:4b-16k
4. Responses flow back to agent
5. All data persists in Docker volumes

Features:
✓ No GPU acceleration (CPU-based for M2 compatibility)
✓ Memory optimized for 8GB RAM systems
✓ Clean isolation via containers
✓ Persistent storage via volumes
✓ Easy setup and management
```
