import React, { useCallback, useEffect, useState } from "react"
import PixelToken from "./contracts/PixelToken.json"
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
import { displayScreen } from "./utils/viewport"
import * as PIXI from "pixi.js"
import { viewport } from "./utils/index"

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
    displayScreen()
    return () => {
      if (web3) {
        web3.eth.unsubscribe((error, success) => {
          if (success) {
            console.log(success)
          }
        })
      }
    }
  }, [])

  useEffect(() => {
    viewport.on("clicked", async (el) => {
      console.log(contract)
      if (contract) {
        await contract.methods
          .create(Math.round(el.world.x), Math.round(el.world.y), "black")
          .send({
            from: accounts[0],
            value: web3.utils.toWei(".01", "ether"),
          })
        fetchPixels(contract)
      }
    })
  }, [contract])

  const addPixel = (meta) => {
    const sprite = viewport.addChild(new PIXI.Sprite(PIXI.Texture.WHITE))
    sprite.tint = stc(meta.account).replace("#", "0x")
    sprite.width = sprite.height = 10
    sprite.position.set(meta.x, meta.y)
  }

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
              {addPixel(pixel.meta)}
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
