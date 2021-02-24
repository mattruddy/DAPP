import React from "react";
import { ChromePicker } from "react-color";

export default ({ color, onColorChange }) => {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "row",
      }}
    >
      <ChromePicker
        color={color}
        onChange={onColorChange}
        disableAlpha={true}
      />
    </div>
  );
};
