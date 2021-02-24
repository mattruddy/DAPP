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

  const handleClicked = useCallback(
    (el) => {
      if (isEdit) {
        const newPoint = {
          x: Math.floor(el.world.x),
          y: Math.floor(el.world.y),
          color: currentColor,
        };
        const match = (s) => newPoint.x === s.x && newPoint.y === s.y;
        const notMatch = (s) => !match(s);
        // clicked an already selected pixel?
        if (selectedPixels.some(match)) {
          setSelectedPixels((curr) => curr.filter(notMatch));
          setCurrPixels((curr) => curr.filter(notMatch));
        } else {
          setSelectedPixels((curr) => [...curr, newPoint]);
          setCurrPixels((curr) => [...curr, newPoint]);
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

  return (
    <div style={{ padding: "16px" }} ref={worldRef} className="world"></div>
  );
};

export default World;
