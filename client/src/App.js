import React, { Component, useEffect, useState } from "react";
import PixelToken from "./contracts/PixelToken.json";
import getWeb3 from "./getWeb3";

import "./App.css";

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState();
  const [contract, setContract] = useState();

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
      const deployedNetwork = PixelToken.networks[networkId];
      const instance = new web3.eth.Contract(
        PixelToken.abi,
        deployedNetwork && deployedNetwork.address
      );

      setWeb3(web3);
      setAccounts(accounts);
      setContract(instance);

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

  const handleCreate = async (e) => {
    e.preventDefault();

    console.log(contract);

    if (contract) {
      console.log(
        await contract.methods.create(accounts[0], 10000000000).send({
          from: accounts[0],
        })
      );
    }
  };

  const handleSend = async (e) => {
    e.preventDefault();

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

  if (!web3) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App">
      <button onClick={(e) => handleCreate(e)}>Create Token</button>

      <button onClick={(e) => handleSend(e)}>Send</button>
    </div>
  );
};

export default App;
