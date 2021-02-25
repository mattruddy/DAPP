import React, { useCallback, useEffect, useState } from "react";
import PixelToken from "./contracts/PixelToken.json";
import getWeb3 from "./getWeb3";
import {
  Button,
  Input,
  InputGroup,
  Modal,
  ModalBody,
  ModalHeader,
} from "reactstrap";

import "./App.css";
import World from "./components/World";
import SidePanel from "./components/SidePanel";
import { useRecoilState, useSetRecoilState } from "recoil";
import { isEditState, selectedPixelsState } from "./state";

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState();
  const [contract, setContract] = useState();
  const [pixels, setPixels] = useState([]);
  const [to, setTo] = useState();
  const [sendId, setSendId] = useState();
  const [isOpen, setIsOpen] = useState(false);
  const [isEdit, setIsEdit] = useRecoilState(isEditState);
  const setSelectedPixels = useSetRecoilState(selectedPixelsState);

  useEffect(() => {
    start();
    return () => {
      if (web3) {
        web3.eth.unsubscribe((error, success) => {
          if (success) {
          }
        });
      }
    };
  }, []);

  // useEffect(() => {
  //   viewport.on("clicked", async (el) => {
  //     console.log(contract);
  //     if (contract) {
  //       await contract.methods
  //         .create(Math.round(el.world.x), Math.round(el.world.y), "black")
  //         .send({
  //           from: accounts[0],
  //           value: web3.utils.toWei(".01", "ether"),
  //         });
  //       fetchPixels(contract);
  //     }
  //   });
  // }, [contract]);

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

      web3.eth
        .subscribe("logs", { address: instance.address }, (error, result) => {})
        .on("data", (data) => {});

      setWeb3(web3);
      setAccounts(accounts);
      setContract(instance);
      fetchPixels(instance);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      );
      console.error(error);
    }
  };

  const fetchPixels = async (instance) => {
    const p = await instance.methods.getPixels().call();
    console.log("p", p);
    setPixels(
      p.map(({ x, y, hexColor }) => ({
        x: parseInt(x),
        y: parseInt(y),
        color: hexColor,
      }))
    );
  };

  const toggle = () => setIsOpen(!isOpen);

  const handleSend = useCallback(async () => {
    if (to) {
      await contract.methods.send(to, sendId).send({
        from: accounts[0],
      });
      fetchPixels(contract);
    }
  }, [accounts, to, contract]);

  const handleCheckout = async (selected) => {
    if (contract) {
      const valsToSend = selected.map(({ x, y, color }) => ({
        x,
        y,
        hexColor: color,
        id: web3.utils.fromAscii("null"),
      }));
      await contract.methods.create(valsToSend).send({
        from: accounts[0],
        value: web3.utils.toWei(".01", "ether"),
      });
      setSelectedPixels([]);
      setIsEdit(false);
      fetchPixels(contract);
    }
  };

  if (!web3) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App">
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          margin: "8px",
        }}
      >
        <h5>Crypto Pixels</h5>
        <Button onClick={() => setIsEdit(!isEdit)}>
          {!isEdit ? "Buy" : "Cancel"}
        </Button>
      </div>
      <div
        style={{
          display: "flex",
          alignItems: "stretch",
          justifyContent: "center",
          margin: "8px",
        }}
      >
        <World pixels={pixels} />
        {isEdit && <SidePanel onCheckout={handleCheckout} />}
      </div>
      <Modal isOpen={isOpen}>
        <ModalHeader>Send Pixel?</ModalHeader>
        <ModalBody>
          <InputGroup>
            <Input onChange={(e) => setTo(e.target.value)} value={to} />
          </InputGroup>
          <InputGroup>
            <Button
              onClick={(e) => {
                e.preventDefault();
                handleSend();
              }}
            >
              Send
            </Button>
          </InputGroup>
          <InputGroup>
            <Button
              onClick={(e) => {
                e.preventDefault();
                setSendId(undefined);
                toggle();
              }}
            >
              Close
            </Button>
          </InputGroup>
        </ModalBody>
      </Modal>
    </div>
  );
};

export default App;
