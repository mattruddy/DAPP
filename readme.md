# DAPP

## Set up

- Install truffle

### 1.

Start truffle backend

```bash
truffle develop
```

### 2.

In the truffle console, deploy smart contract to local blockchain

```bash
> migrate --reset
```

### 3.

cd into `client`

```bash
npm start
```

### 4.

Add euther to meta mask wallet

```bash
web3.eth.sendTransaction({'from': accounts[0], 'to': {public address}, 'value': web3.utils.toWei('3', 'ether')})
```

where `{public address}` is your metamask address.
