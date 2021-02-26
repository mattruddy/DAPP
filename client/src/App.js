import React, { useCallback, useEffect, useState } from "react"
import PixelToken from "./contracts/PixelToken.json"
import getWeb3 from "./getWeb3"
import { Button } from "reactstrap"

import "./App.css"
import World from "./components/World"
import SidePanel from "./components/SidePanel"
import { useRecoilState, useSetRecoilState } from "recoil"
import { isEditState, selectedPixelsState } from "./state"

const App = () => {
  const [web3, setWeb3] = useState(null)
  const [accounts, setAccounts] = useState()
  const [contract, setContract] = useState()
  const [pixels, setPixels] = useState([])
  const [bids, setBids] = useState([])
  const [isEdit, setIsEdit] = useRecoilState(isEditState)
  const setSelectedPixels = useSetRecoilState(selectedPixelsState)

  useEffect(() => {
    start()
    return () => {
      if (web3) {
        web3.eth.unsubscribe((error, success) => {
          if (success) {
          }
        })
      }
    }
  }, [])

  const start = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3()
      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts()

      // Get the contract instance.
      const networkId = await web3.eth.net.getId()
      const deployedNetwork = PixelToken.networks[networkId]
      const instance = new web3.eth.Contract(
        PixelToken.abi,
        deployedNetwork && deployedNetwork.address
      )

      web3.eth
        .subscribe("logs", { address: instance.address }, (error, result) => {})
        .on("data", (data) => {})

      setWeb3(web3)
      setAccounts(accounts)
      setContract(instance)
      fetchPixels(instance)
      getBids(instance)
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      )
      console.error(error)
    }
  }

  const fetchPixels = async (instance) => {
    const p = await instance.methods.getPixels().call()
    console.log("p", p)
    setPixels(
      p.map(({ x, y, hexColor }) => ({
        x: parseInt(x),
        y: parseInt(y),
        color: hexColor,
      }))
    )
  }

  const getBids = async (instance) => {
    const b = await instance.methods.getBids().call()
    setBids(
      b.map(({ fromAddress, amount }) => ({
        from: fromAddress,
        amount: amount,
      }))
    )
  }

  const handleBid = async () => {
    await contract.methods.placeBid(0).send({
      from: accounts[0],
      value: web3.utils.toWei(".2", "ether"),
    })
  }

  const handleCheckout = async (selected) => {
    if (contract) {
      const valsToSend = selected.map(({ x, y, color }) => ({
        x,
        y,
        hexColor: color,
        id: web3.utils.fromAscii("null"),
        owner: accounts[0],
        creatorId: 0,
      }))
      await contract.methods.create(valsToSend).send({
        from: accounts[0],
        value: web3.utils.toWei(".01", "ether"),
      })
      setSelectedPixels([])
      setIsEdit(false)
      fetchPixels(contract)
    }
  }

  if (!web3) {
    return <div>Loading Web3, accounts, and contract...</div>
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
        <Button onClick={handleBid}>Bid</Button>
        <ul>
          {bids &&
            bids.map((b, i) => (
              <li key={i}>
                <div>
                  <b>Ether</b> {web3.utils.fromWei(b.amount)}
                </div>
                <div>
                  <b>From</b> {b.from}
                </div>
              </li>
            ))}
        </ul>
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
    </div>
  )
}

export default App
