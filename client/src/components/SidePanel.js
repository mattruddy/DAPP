import React, { useState } from "react";
import { ChromePicker } from "react-color";
import { useRecoilState, useRecoilValue } from "recoil";
import { currentColorState, selectedPixelsState } from "../state";
import { Button, Modal, ModalFooter, ModalBody } from "reactstrap";

export default () => {
  const [selectedPixels, setSelectedPixels] = useRecoilState(
    selectedPixelsState
  );
  const [currentColor, setCurrentColor] = useRecoilState(currentColorState);
  const [showClearModal, setShowClearModal] = useState(false);

  const clearSelected = () => {
    setSelectedPixels([]);
    toggleClearModal();
  };
  const toggleClearModal = () => setShowClearModal(!showClearModal);

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-evenly",
        borderRight: "1px solid black",
        borderBottom: "1px solid black",
        borderTop: "1px solid black",
        padding: "8px",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
        }}
      >
        <div>Selected Pixels</div>
        <div>{selectedPixels.length}</div>
      </div>
      <ChromePicker
        color={currentColor}
        onChange={(color) => setCurrentColor(color.hex)}
        disableAlpha={true}
        style={{
          padding: "8px",
        }}
      />
      <div
        style={{
          display: "flex",
          flexDirection: "row",
          justifyContent: "center",
          border: "1px solid black",
        }}
      >
        <Button style={{ padding: "8px" }} onClick={() => toggleClearModal()}>
          Clear
        </Button>
      </div>
      <Modal isOpen={showClearModal} toggle={() => toggleClearModal()}>
        <ModalBody>Are you sure you want to clear?</ModalBody>
        <ModalFooter>
          <Button onClick={() => toggleClearModal()} variant="secondary">
            Cancel
          </Button>
          <Button onClick={() => clearSelected()} variant="primary">
            Clear
          </Button>
        </ModalFooter>
      </Modal>
    </div>
  );
};
