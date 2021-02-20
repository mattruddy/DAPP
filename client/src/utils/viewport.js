import {app, viewport} from './index'

export const displayScreen = () => {
  document.body.appendChild(app.view)
  // add the viewport to the stage
  app.stage.addChild(viewport)
  // activate plugins
  viewport.drag().pinch().wheel().decelerate().fitWorld()
}
