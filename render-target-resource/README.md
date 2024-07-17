# Render target resource example

This example showcases the use of render target resources in GUIs in Defold.

The basic setup of this example is:

* A render target resource - this is where the results of the map should be drawn to
* An atlas that is dynamically updated - the atlas contains a blank texture. It will be updated with the render target in the runtime. This is because we need to set the atlas resource in the GUI as a starting point.
* The main.script updates the atlas with the render target resource in the init() function - basically, we retrieve the render target texture of the resource and update the animation so that it encompasses the entire render target texture. The GUI is already configured to use this animation, we simply update it once so that it uses the render target.

## License

* The art assets are made by kenney, all rights belong to him (https://kenney.nl/)
