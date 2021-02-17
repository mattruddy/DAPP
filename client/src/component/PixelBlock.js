import React from "react"
import stc from "string-to-color"

const PixelBlock = (props) => {
    console.log(props.pixel)
  return (
    <div>
      {props.pixel && (
        <div
          className="pixel"
          style={{ background: `${stc(props.pixel.meta.account)}` }}
        />
      )}
    </div>
  )
}

export default PixelBlock
