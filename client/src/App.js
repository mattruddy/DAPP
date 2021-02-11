import React, { Component, useEffect, useState } from "react";
import AmericaContract from "./contracts/America.json";
import getWeb3 from "./getWeb3";

import "./App.css";

const App = () => {
  const [storageValue, setStorageValue] = useState(0);
  const [web3, setWeb3] = useState(null);

  useEffect(() => {
    start();
  }, []);

  const start = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = AmericaContract.networks[networkId];
      const instance = new web3.eth.Contract(
        AmericaContract.abi,
        deployedNetwork && deployedNetwork.address
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance });

      console.log(accounts[0]);

      console.log(await instance.methods.balanceOf(accounts[0], 1).call());
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.error(error);
    }
  };

  handleCreate = async (e) => {
    e.preventDefault();
    const { contract, accounts, web3 } = this.state;

    console.log(contract);

    if (contract) {
      console.log(
        await contract.methods.create(accounts[0], 10000000000).send({
          from: accounts[0],
        })
      );
    }
  };

  handleSend = async (e) => {
    e.preventDefault();
    const { contract, accounts } = this.state;

    contract.methods
      .safeTransferFrom(
        accounts[0],
        "0x81431b69B1e0E334d4161A13C2955e0f3599381e",
        1,
        10000,
        Buffer.from("test")
      )
      .send({
        from: accounts[0],
      });
  };

  if (!this.state.web3) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App">
      <button onClick={(e) => this.handleCreate(e)}>Create Token</button>

      <button onClick={(e) => this.handleSend(e)}>Send</button>
    </div>
  );
};

export default App;
