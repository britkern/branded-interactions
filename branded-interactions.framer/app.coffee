# <@>

# ------------------------------------------------------
# overall setup
# ------------------------------------------------------
# colours used throughout
mint = "rgba(45, 215, 170, 1)"
mint0 = "rgba(45, 215, 170, 0)"
aqua = "#28affa"
purple = "#877DD7"
grey = "#333333"
dark = "#222222"
white = "#FFFFFF"
white80 = "rgba(255, 255, 255, 0.8)"
white20 = "rgba(255, 255, 255, 0.2)"
black50 = "rgba(0, 0, 0, 0.5)"
black20 = "rgba(0, 0, 0, 0.2)"
transparent = "rgba(0, 0, 0, 0)"
# style
squareStyle = 
	"font-family": "Px Grotesk, -apple-system,  Helvetica Neue"
	"font-size": "18pt"
	"line-height": "600px"
	"text-align": "center"
	"text-transform": "uppercase"
	"color": black50
	
presetStyle = 
	"font-family": "Px Grotesk, -apple-system,  Helvetica Neue"
	"font-size": "18pt"
	"line-height": "100px"
	"text-align": "center"
	"text-transform": "uppercase"
	"color": white80
# 	"padding": "10pt 60pt"
	"background-color": black20

# animation presents
sluggishSpeed = 
	curve: "spring(120, 20, 0)"
slowSpeed = 
	curve: "spring(120, 20, 0)"
smoothSpeed = 
	time: 2
	curve: "ease-in-out"
dynamicSpeed = 
	curve: "spring(120, 20, 0)"	
snappySpeed = 
	curve: "spring(600, 30, 0)"
blitzSpeed = 
	curve: "spring(620, 20, 0)"

# default to snappySpeed
Framer.Defaults.Animation = snappySpeed

# bg layer
bg = new BackgroundLayer
	backgroundColor: grey


# ------------------------------------------------------
# left side
# ------------------------------------------------------
left = new Layer
	width: Screen.width/2, height: Screen.height
	backgroundColor: mint

# -----------------------------
# left side: slider
# -----------------------------
sliderWidth = left.width/2
sliderSize = 
	width: sliderWidth
	height: 24
sliderGutter = sliderSize.height * 5

sliderCanvas = new Layer
	width: sliderWidth
	height: (sliderSize.height * 3) + (sliderGutter * 2)
	midX: left.width/2, midY: left.height/2
	backgroundColor: null
	superLayer: left
	clip: false

sliderHolder = new Layer
	width: sliderCanvas.width * 1.4, height: sliderCanvas.height * 1.8
	midX: sliderCanvas.midX, midY: sliderCanvas.midY
	borderRadius: 12
	backgroundColor: white20
	superLayer: left
sliderCanvas.bringToFront()
	
# array that will store our right page layers
sliders = []

for i in [0..2]
	slider = new SliderComponent
		y: i * (sliderSize.height + sliderGutter)
		width: sliderWidth, height: sliderSize.height
		backgroundColor: white20
		knobSize: 48
		min: 0, max: 1, value: 0.5
		superLayer: sliderCanvas
	slider.fill.backgroundColor = white80
	
	sliders.push(slider)

# rename for easy access
tension = sliders[0]
friction = sliders[1]
velocity = sliders[2]

# -----------------------------
# slider logic: spring

# spring values in an array
springValues = [tension, friction, velocity]

# defaults
t = tension.value
f = friction.value
v = velocity.value



# -----------------------------
# left side: presets (pages)
# -----------------------------
presets = new PageComponent 
	midX: sliderHolder.midX, maxY: sliderHolder.y - 50
	width: sliderHolder.width * 1.05
	height: 100
	scrollVertical: false
	superLayer: left

presetsMaskStyle = "background": "-webkit-linear-gradient(left, #{mint} 2%, #{mint0} 4%, #{mint0} 96%, #{mint} 98%)"

presetsMaskStyleRight = "background": "-webkit-linear-gradient(left, #{mint0} 96%, #{mint} 98%)"

presetsMaskStyleLeft = "background": "-webkit-linear-gradient(left, #{mint} 2%, #{mint0} 4%)"

presetsMask = new Layer
	width: presets.width, height: presets.height
	midX: presets.midX, y: presets.y
	style: presetsMaskStyle
	superLayer: left

allPresets = []
# Create layers in a for-loop
for i in [0...6]
	preset = new Layer 
		superLayer: presets.content
		width: 150
		height: 100
		clip: false
		x: 180 * i
		style: presetStyle
		borderRadius: 6
		opacity: 0.3
	allPresets.push(preset)
	
allPresets[0].html = "sluggish"
allPresets[0].name = "sluggish"
sluggish = allPresets[0]
allPresets[1].html = "slow"
allPresets[1].name = "slow"
slow = allPresets[1]
allPresets[2].html = "smooth"
allPresets[2].name = "smooth"
smooth = allPresets[2]
allPresets[3].html = "dynamic"
allPresets[3].name = "dynamic"
dynamic = allPresets[3]
allPresets[4].html = "snappy"
allPresets[4].name = "snappy"
snappy = allPresets[4]
allPresets[5].html = "blitz"
allPresets[5].name = "blitz"
blitz = allPresets[5]

# staging
presets.snapToPage(allPresets[3], false)
presets.currentPage.opacity = 1


# ------------------------------------------------------
# right side: pages, indicators, save
# ------------------------------------------------------
right = new PageComponent
	x: Screen.width/2
	width: Screen.width/2, height: Screen.height
	scrollVertical: false
	backgroundColor: grey
	
# array that will store our right page layers
rightPages = []

# array that will store our right indicator layers
rightIndicators = []	
rightIndicatorsAmount = 3
rightIndicatorsSize = 12

# generate page and indicator layers
for i in [0...rightIndicatorsAmount]
	rightPage = new Layer 
		width: right.width, height: right.height
		x: right.width * i, superLayer: right.content
		backgroundColor: null
		
	# store right page layers in an array
	rightPages.push(rightPage)
		
	indicator = new Layer 
		backgroundColor: white
		width: rightIndicatorsSize, height: rightIndicatorsSize
		x: 28 * i, y: right.maxY - 100
		borderRadius: "50%", opacity: 0.2
		superLayer: right
		
	# Stay centered regardless of the amount of cards
	indicator.x += (right.width / 2) - (rightIndicatorsSize * rightIndicatorsAmount)
	
	# States
	indicator.states.add active: opacity: 0.8, scale:1.2
	indicator.states.animationOptions = time: 0.5
	
	# Store indicators in our array
	rightIndicators.push(indicator)

# set indicator for our current right page
rightCurrent = right.horizontalPageIndex(right.currentPage)
rightIndicators[rightCurrent].states.switch("active")
	
# rename for easy access
rightOne = rightPages[0]
rightTwo = rightPages[1]
rightThree = rightPages[2]

# -----------------------------
# right side: basic interactions
# -----------------------------
squareSize = right.width/3
boundsSize = 
	width: squareSize
	height: squareSize
gutter = boundsSize.width*0.2

squareCanvas = new Layer
	midX: rightOne.width/2, midY: rightOne.height/2
	width: (boundsSize.width * 2) + (gutter * 1)
	height: (boundsSize.height * 2) + (gutter * 1)
	backgroundColor: null
	superLayer: rightOne
	clip: false
	
interactions = []
rows = 2
cols = 2

[0..rows-1].map (a) ->
	[0..cols-1].map (b) ->
		i = new Layer
			size: boundsSize
			x: a * (boundsSize.width + gutter)
			y: b * (boundsSize.height + gutter)
			backgroundColor: white20
			borderRadius: 12
			clip: false
			style: squareStyle
			superLayer: squareCanvas
				
		interactions.push(i)

# rename these layers to make them handy
scale = interactions[0]
scale.name = "scale"
scale.html = scale.name

rotate = interactions[1]
rotate.name = "rotate"
rotate.html = rotate.name

position = interactions[2]
position.name = "position"
position.html = position.name

opacity = interactions[3]
opacity.name = "opacity"
opacity.html = opacity.name

interactionsTargets = []

# -----------------------------
# scale
scaleTarget = new Layer
	size: boundsSize
	scale: 0.5
	backgroundColor: white80
	borderRadius: 24
	superLayer: scale
interactionsTargets.push(scaleTarget)

scaleTarget.states.add
	last: scale: 0.95, borderRadius: 12

scale.on Events.Click, ->
	scaleTarget.states.next()


# -----------------------------
# rotate
rotateTarget = new Layer
	size: boundsSize
	scale: 0.5
	backgroundColor: white80
	borderRadius: 24
	superLayer: rotate
interactionsTargets.push(rotateTarget)	
	
rotateTarget.states.add
	last: rotation: 90, borderRadius: 12

rotate.on Events.Click, ->
	rotateTarget.states.next()
	
# -----------------------------
# position
positionTarget = new Layer
	size: boundsSize
	scale: 0.5
	backgroundColor: white80
	borderRadius: 24
	superLayer: position
interactionsTargets.push(positionTarget)	

positionTarget.states.add
	first: x: positionTarget.x - boundsSize.width/4
	last: x: positionTarget.x + boundsSize.width/4

position.on Events.Click, ->
	positionTarget.states.next()


# -----------------------------
# opacity
opacityTargetTop = new Layer
	size: boundsSize
	scale: 0.5
	backgroundColor: null
	borderWidth: 5
	borderColor: white80
	borderRadius: 24
	superLayer: opacity
	
opacityTarget = new Layer
	size: boundsSize
	scale: 0.5
	backgroundColor: white80
	borderRadius: 24
	superLayer: opacity
interactionsTargets.push(opacityTarget)

opacityTarget.states.add
	last: opacity: 0
	
opacity.on Events.Click, ->
	opacityTarget.states.next()
	

# -----------------------------
# right side: iphone #1
# -----------------------------
iphone = new Layer
	midX: rightOne.width/2, midY: rightOne.height/2
	width: 994, height: 2028
	scale: 0.5, opacity: 0.2
	image: "images/iphone.png"
	superLayer: rightTwo 

iphoneTarget = new Layer
	width: boundsSize.width, height: boundsSize.height/2
	midX: rightOne.width/2, midY: rightOne.height/2
	backgroundColor: white80
	borderRadius: 6
	superLayer: rightTwo
	originX: 0.5
interactionsTargets.push(iphoneTarget)

iphoneTarget.states.add
	# opacity & position
	first:
		opacity: 0.6, maxY: 1000, width: (boundsSize.width + 100), midX: (rightOne.width/2)
	second: rotation: 90
	last: scale: 2
	
iphoneTarget.on Events.Click, ->
	iphoneTarget.states.next()

	
# ------------------------------------------------------
# left side: changes
# ------------------------------------------------------
presets.on "change:currentPage", ->
	# animate out previousPage
	presets.previousPage.animate 
		properties:
			opacity: 0.3
		time: 0.4
	# animate in new currentPage
	presets.currentPage.animate 
		properties:
			opacity: 1
		time: 0.4
		
	if presets.currentPage is sluggish
		for i in interactionsTargets
			i.states.animationOptions = sluggishSpeed
		presetsMask.style = presetsMaskStyleRight
		
	else if presets.currentPage is slow
		for i in interactionsTargets
			i.states.animationOptions = slowSpeed
		presetsMask.style = presetsMaskStyle		
	else if presets.currentPage is smooth
		for i in interactionsTargets
			i.states.animationOptions = smoothSpeed
		presetsMask.style = presetsMaskStyle		
	else if presets.currentPage is dynamic
		for i in interactionsTargets
			i.states.animationOptions = dynamicSpeed
		presetsMask.style = presetsMaskStyle
		
	else if presets.currentPage is snappy
		for i in interactionsTargets
			i.states.animationOptions = snappySpeed
		presetsMask.style = presetsMaskStyle
		
	else if presets.currentPage is blitz
		for i in interactionsTargets
			i.states.animationOptions = blitzSpeed
		presetsMask.style = presetsMaskStyleLeft
		
	else # edge-cases, default speed
		for i in interactionsTargets
			i.states.animationOptions = snappySpeed
		presetsMask.style = presetsMaskStyle
			
	# reset states
	scaleTarget.states.switch("default")
	# rotateTarget.states.switch("default")
	positionTarget.states.switch("default")
	opacityTarget.states.switch("default")
			
		
for i in allPresets
	i.on Events.Click, ->
		presets.snapToPage(this)

# ------------------------------------------------------
# right side: changes
# ------------------------------------------------------
right.on "change:currentPage", ->
	# Update indicators: remove old
	indicator.states.switch("default") for indicator in rightIndicators
	# Update indicators: update new
	rightCurrent = right.horizontalPageIndex(right.currentPage)
	rightIndicators[rightCurrent].states.switch("active")
	
	# reset states
	scaleTarget.states.switch("default")
	# rotateTarget.states.switch("default")
	positionTarget.states.switch("default")
	opacityTarget.states.switch("default")
	


	
