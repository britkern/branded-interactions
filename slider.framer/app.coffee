target = new Layer
	midX: Screen.width/2, midY: Screen.height/2 - 150

tensionSlider = new SliderComponent
	midY: Screen.height/2 + 50
	min: 0, max: 800, value: 400		
frictionSlider = new SliderComponent
	midY: Screen.height/2 + 100
	min: 0, max: 100, value: 20	
velocitySlider = new SliderComponent
	midY: Screen.height/2 + 150
	min: 0, max: 25, value: 0	
	
allSliders = [tensionSlider, frictionSlider, velocitySlider]
for slider in allSliders
	slider.midX = Screen.width/2
	slider.knob.draggable.momentum = false
	slider.html = "#{slider.value}"
	slider.style = 
		"font-family": "Px Grotesk, -apple-system,  Helvetica Neue"
		"color": "black"
		"padding-top": "10px"
		"font-size": "0.5em"
		
		
	slider.onValueChange ->
		target.states.animationOptions =
			curve: "spring(#{tensionSlider.value}, #{frictionSlider.value}, #{velocitySlider.value})"
		this.html = Utils.round("#{this.value}")
	
target.states = 
	end: rotation: 90
	animationOptions:
		curve: "spring(#{tensionSlider.value}, #{frictionSlider.value}, #{velocitySlider.value})"
target.onTap ->
	this.stateCycle()
	
	
saveButton = new Layer
	midX: Screen.width/2, maxY: Screen.height-50
	height: 48
	html: "Save"
	style:
		"font-family": "Px Grotesk, -apple-system,  Helvetica Neue"
		"text-align": "center"