# NFT Marketplace – Development Container

This development container provides a consistent and pre-configured environment to build, run, and test the NFT Marketplace project. It includes all required tools and dependencies for a full-stack Web3 development workflow.

## Prerequisites

Ensure the following tools are installed on your host machine before using the dev container:

- [Docker](https://www.docker.com/get-started/)
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

> 💡 You can also use another IDE that supports development containers if you prefer.

## Getting Started

1. **Clone the Repository**
    ```bash
    git clone https://github.com/cyfrin/ts-nft-marketplace-cu
    ```

2. **Open in VS Code**
    - Launch VS Code.
    - Open the cloned project folder.

3. **Open in Dev Container**
    - Press `F1` (or `Cmd + Shift + P` on macOS).
    - Select `Dev Containers: Reopen in Container`.
    - VS Code will build the container and open the workspace inside it.

## Notes

- When running the local Anvil blockchain, **you must make it accessible to the host machine**.
  
  Use the following command instead of the default:
  ```bash
  pnpm anvil --host 0.0.0.0
  ```

  This ensures Metamask (or any client outside the container) can connect to the Anvil instance.
