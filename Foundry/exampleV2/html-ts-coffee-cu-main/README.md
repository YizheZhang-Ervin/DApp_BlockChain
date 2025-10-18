# HTML TS Buy Me A Coffee

This is a website for the minimal code form the foundry full course, in specific, the `FundMe` codebase, which can be found here:

https://github.com/Cyfrin/foundry-fund-me-cu

- [HTML TS Buy Me A Coffee](#html-ts-buy-me-a-coffee)
- [Setup (Both Javascript and Typescript Editions)](#setup-both-javascript-and-typescript-editions)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
    - [Javascript Edition](#javascript-edition)
      - [Quickstart](#quickstart-1)
    - [Typescript Edition](#typescript-edition)
      - [Requirements](#requirements-1)
      - [Quickstart](#quickstart-2)

There are 2 different ways to run this codebase.

1. Javascript Edition

2. Typescript Edition

# Setup (Both Javascript and Typescript Editions)

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you've installed it right if you can run: `git --version`
- [Metamask](https://metamask.io/)
  - This is a browser extension that lets you interact with the blockchain.
- [anvil](https://book.getfoundry.sh/reference/anvil/)
  - You'll know you've installed it right if you can run: `anvil --version` 

## Quickstart

1. Clone the repository

```bash
git clone https://github.com/Cyfrin/html-ts-coffee-cu
cd html-ts-coffee-cu
```

2. Run the following command:

```bash
anvil --load-state fundme-anvil.json 
```

This will load a local blockchain with our smart contract already deployed.

3. Import the anvil key into your Metamask

When you run the `anvil` command from #1, it'll give you a list of private keys. [Import one into your metamask.](https://support.metamask.io/start/how-to-import-an-account/)

You'll now have a wallet with some funds associated with our anvil chain!

4. Add the anvil chain to your metamask

[Follow this](https://support.metamask.io/configure/networks/how-to-add-a-custom-network-rpc/) and use:
- Network name: Anvil
- New RPC URL: http://127.0.0.1:8545
- Chain ID: 31337
- Currency Symbol: ETH
- Block Explorer URL: None

### Javascript Edition 

After doing the setup above, do the following

#### Quickstart

1. Run the `index.html` file

You can usually just double click the file to "run it in the browser". Or you can right click the file in your VSCode and run "open with live server" if you have the live server VSCode extension (ritwickdey.LiveServer).

And you should see a small button that says "connect".

![Connect](connect.png)

Hit it, and you should see metamask pop up.

2. Press some buttons!

### Typescript Edition

After doing the setup from above, do the following

#### Requirements

- All the requirements for the [Javascript Edition](#requirements)
- [pnpm](https://pnpm.io/)
  - You'll know you've installed it right if you can run:`pnpm --version`
- [Node.js](https://nodejs.org/en/)
  - You'll know you've installed it right if you can run: `node --version`

#### Quickstart

1. Install the dependencies

```bash
pnpm install
```

2. Uncomment the line with `index-ts.ts` line in your `index.html` file, and comment out the line with `index-js.js`. Like this:

```html
<script src="./index-ts.ts" type="module"></script>
<!-- <script src="./index-js.js" type="module"></script> -->
```

3. Run the following command:

```bash
pnpm run dev
```

3. Open your browser to whatever the command above says, ie: `http://localhost:5173/`

4. Press some buttons!