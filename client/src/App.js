import React, { useCallback, useEffect, useState } from "react"
import PixelToken from "./contracts/PixelToken.json"
import PixelBlock from "./component/PixelBlock"
import getWeb3 from "./getWeb3"
import stc from "string-to-color"
import {
  Button,
  Input,
  InputGroup,
  Modal,
  ModalBody,
  ModalHeader,
} from "reactstrap"

import "./App.css"

const App = () => {
  const [web3, setWeb3] = useState(null)
  const [accounts, setAccounts] = useState()
  const [contract, setContract] = useState()
  const [pixels, setPixels] = useState([])
  const [to, setTo] = useState()
  const [sendId, setSendId] = useState()
  const [isOpen, setIsOpen] = useState(false)

  useEffect(() => {
    start()
  }, [])

  const start = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3()
      web3.eth.subscribe(
        "logs",
        { address: "0x93F3FF8fBA0386F84016DbCEBd7B922B3094c5C9" },
        (error, result) => {
          if (error) {
            console.log(error)
          } else {
            console.log(result)
          }
        }
      )
      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts()

      // Get the contract instance.
      const networkId = await web3.eth.net.getId()
      const deployedNetwork = PixelToken.networks[networkId]
      const instance = new web3.eth.Contract(
        PixelToken.abi,
        deployedNetwork && deployedNetwork.address
      )

      setWeb3(web3)
      setAccounts(accounts)
      setContract(instance)
      fetchPixels(instance)
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`
      )
      console.error(error)
    }
  }

  const fetchPixels = async (instance) => {
    const p = await instance.methods.getAllPixels().call()
    setPixels(p)
  }

  const handleCreate = async (e) => {
    e.preventDefault()
    if (contract) {
      await contract.methods.create(1, 1, "black").send({
        from: accounts[0],
        value: web3.utils.toWei(".01", "ether"),
      })
      fetchPixels(contract)
    }
  }

  const toggle = () => setIsOpen(!isOpen)

  const handleSend = useCallback(async () => {
    if (to) {
      await contract.methods.send(to, sendId).send({
        from: accounts[0],
      })
      fetchPixels(contract)
    }
  }, [accounts, to, contract])

  if (!web3) {
    return <div>Loading Web3, accounts, and contract...</div>
  }
  return (
    <div className="App">
      <div
        style={{
          display: "flex",
          alignItems: "center",
          margin: "8px",
        }}
      >
        <h5>My Pixel Color </h5>
        {accounts && (
          <div
            className="pixel"
            style={{ background: `${stc(accounts[0])}` }}
          />
        )}
      </div>
      <button onClick={(e) => handleCreate(e)}>Create Pixel</button>
      {/* <input onChange={(e) => setTo(e.target.value)} value={to} /> */}
      <ul>
        {pixels &&
          pixels.map((pixel, i) => (
            <div
              key={i}
              onClick={(e) => {
                e.preventDefault()
                setSendId(pixel.id)
                toggle()
              }}
            >
              <PixelBlock pixel={pixel} />
            </div>
          ))}
      </ul>
      <Modal isOpen={isOpen}>
        <ModalHeader>Send Pixel?</ModalHeader>
        <ModalBody>
          <InputGroup>
            <Input onChange={(e) => setTo(e.target.value)} value={to} />
          </InputGroup>
          <InputGroup>
            <Button
              onClick={(e) => {
                e.preventDefault()
                handleSend()
              }}
            >
              Send
            </Button>
          </InputGroup>
          <InputGroup>
            <Button
              onClick={(e) => {
                e.preventDefault()
                setSendId(undefined)
                toggle()
              }}
            >
              Close
            </Button>
          </InputGroup>
        </ModalBody>
      </Modal>
    </div>
  )
}

export default App
