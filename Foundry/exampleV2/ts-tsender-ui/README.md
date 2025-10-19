# TSender UI

A 100% client-side UI for the TSender contract.

Smart Contracts: https://github.com/Cyfrin/TSender/

- [TSender UI](#tsender-ui)
- [Getting Started](#getting-started)
    - [Requirements](#requirements)
        - [Environment Variables](#environment-variables)
    - [Setup](#setup)
- [Testing](#testing)
    - [Unit](#unit)
    - [e2e](#e2e)
- [Contributing](#contributing)

# Getting Started

## Requirements

- [node](https://nodejs.org/en/download)
    - You'll know you've installed it right if you can run `node --version` and get a response like `v23.0.1`
- [pnpm](https://pnpm.io/)
    - You'll know you've installed it right if you can run `pnpm --version` and get a response like `10.1.0`
- [git](https://git-scm.com/downloads)
    - You'll know you've installed it right if you can run `git --version` and get a response like `git version 2.33.0`

### Environment Variables

You'll need a `.env.local` the following environment variables:

- `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`: Project ID from [reown cloud](https://cloud.reown.com/)

## Setup

```bash
git clone https://github.com/cyfrin/tsender-ui
cd tsender-ui
pnpm install
pnpm anvil
```

You'll want to make sure you have a Metamask/Rabby wallet connected to your anvil instance. Ideally you're connected to the wallet that comes with the default anvil instance. This will have some mock tokens in it.

Then, in a second browser run:

```bash
pnpm run dev
```

# Testing

## Unit

```bash
pnpm test:unit
```

## e2e

Playwright should also install the browsers needed to run tests.

To test e2e, do the following

```bash
pnpm cache
```

Then run:

```bash
pnpm test:e2e
```

This will throw an error like:

```
Error: Cache for 08a20e3c7fc77e6ae298 does not exist. Create it first!
```

The `08a20e3c7fc77e6ae298` is your `CACHE_NAME`

In your `.cache-synpress` folder, rename the folder that isn't `metamask-chrome-***` to your `CACHE_NAME`.

Then, you should be able to run:

```
pnpm test:e2e
```

And it'll work!

# Contributing

For those who want to contribute, including running tests, please see the [CONTRIBUTING.md](./CONTRIBUTING.md) file.

<!-- # Install from scratch notes

When adding Tailwind, remember to remove `supports-color` -->

<!-- Testing: -->
<!-- -D vitest @vitejs/plugin-react jsdom @testing-library/react @testing-library/dom vite-tsconfig-paths -->
