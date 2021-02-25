import React, { useEffect, useState, useRef, useCallback } from "react";
import { useRecoilState, useRecoilValue } from "recoil";
import { currentColorState, isEditState, selectedPixelsState } from "../state";

import { SIZE, viewport } from "../utils/index";
import { displayScreen, updateWorld } from "../utils/viewport";

const World = ({ pixels, onPixelsChange }) => {
  const [currPixels, setCurrPixels] = useState(pixels);
  const [selectedPixels, setSelectedPixels] = useRecoilState(
    selectedPixelsState
  );
  const currentColor = useRecoilValue(currentColorState);
  const worldRef = useRef();
  const isEdit = useRecoilValue(isEditState);

  console.log(pixels);

  const handleClicked = useCallback(
    (el) => {
      if (isEdit) {
        const newPoint = {
          x: Math.floor(el.world.x),
          y: Math.floor(el.world.y),
          color: currentColor,
        };
        let selected;
        const match = (s) => newPoint.x === s.x && newPoint.y === s.y;
        const notMatch = (s) => !match(s);
        // clicked an already selected pixel?
        if (selectedPixels.some(match)) {
          selected = selectedPixels.filter(notMatch);
          setSelectedPixels(selected);
        } else {
          selected = [...selectedPixels, newPoint];
          setSelectedPixels(selected);
          onPixelsChange && onPixelsChange({ el, currPixels, selectedPixels });
        }
      }
    },
    [currentColor, isEdit, onPixelsChange, selectedPixels]
  );

  useEffect(() => {
    viewport.addListener("clicked", handleClicked);
    return () => {
      if (viewport) viewport.removeListener("clicked", handleClicked);
    };
  }, [handleClicked]);

  useEffect(() => {
    displayScreen(worldRef.current);
    viewport.screenWidth = worldRef.current.offsetWidth;
    viewport.screenHeight = worldRef.current.offsetHeight;
    viewport.clamp({ direction: "all" });
    viewport.clampZoom({
      maxHeight: SIZE + SIZE * 0.5,
      maxWidth: SIZE + SIZE * 0.5,
      minHeight: 5,
      minWidth: 5,
    });
    viewport.fit();
  }, []);

  useEffect(() => {
    updateWorld(currPixels);
  }, [currPixels]);

  useEffect(() => {
    if (!isEdit) {
      setCurrPixels(pixels);
    } else {
      setCurrPixels([...pixels, ...selectedPixels]);
    }
  }, [isEdit]);

  useEffect(() => {
    if (isEdit) {
      setCurrPixels([...pixels, ...selectedPixels]);
    }
  }, [selectedPixels]);

  useEffect(() => {
    setCurrPixels(pixels);
  }, [pixels]);

  return (
    <div
      style={{
        padding: "16px",
        border: "1px solid black",
      }}
      ref={worldRef}
      className="world"
    ></div>
  );
};

export default World;
