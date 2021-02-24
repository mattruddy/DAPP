import React, { useEffect, useState, useRef, useCallback } from "react";

import { SIZE, viewport } from "../utils/index";
import {
  displayScreen,
  addPixel,
  removePixel,
  updateWorld,
} from "../utils/viewport";

const World = ({ pixels, isEdit, onPixelsChange, currentColor }) => {
  const [currPixels, setCurrPixels] = useState(pixels);
  const [selectedPixels, setSelectedPixels] = useState([]);
  const worldRef = useRef();

  console.log(currentColor);
  const handleClicked = useCallback(
    (el) => {
      if (isEdit) {
        // clicked and already selected pixel.
        // const match = (s) => el.world.x === s.x && el.world.y === s.y;
        // if (selectedPixels.some(match)) {
        //   setSelectedPixels((curr) => curr.filter(match));
        //   removePixel(selectedPixels.find(match));
        // }
        const newPoint = {
          x: Math.floor(el.world.x),
          y: Math.floor(el.world.y),
          color: currentColor.hex,
        };
        setSelectedPixels((curr) => [...curr, newPoint]);
        setCurrPixels((curr) => [...curr, newPoint]);
        onPixelsChange && onPixelsChange({ el, currPixels, selectedPixels });
      }
    },
    [currentColor, isEdit, onPixelsChange]
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
  }, []);
  useEffect(() => {
    updateWorld(currPixels);
  }, [currPixels]);

  useEffect(() => {
    if (!isEdit) {
      setCurrPixels(pixels);
    }
  }, [isEdit]);

  return (
    <div style={{ padding: "16px" }} ref={worldRef} className="world"></div>
  );
};

export default World;
