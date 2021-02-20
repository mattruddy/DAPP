import * as PIXI from "pixi.js"
import { Viewport } from "pixi-viewport"

export const app = new PIXI.Application()

export const viewport = new Viewport({
  screenWidth: window.innerWidth,
  screenHeight: window.innerHeight,
  worldWidth: 1000,
  worldHeight: 1000,

  interaction: app.renderer.plugins.interaction, // the interaction module is important for wheel to work properly when renderer.view is placed or scaled
})
