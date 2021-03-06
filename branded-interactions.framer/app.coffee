# <@>
# Danny White
# ustwo NYC / 2015-16
# https://github.com/ustwo/branded-interactions

# ------------------------------------------------------
# overall setup
# ------------------------------------------------------
document.body.style.cursor = "auto"

window.onresize = ->
	location.reload()

# modules

# http://jrdn.io/d5or
{DPR} = require "DevicePixelRatio"
# Store our base unit
unit = 1
unit = DPR.get(unit)
# print unit

# 2 = iOS (iPad etc)
if unit is 2
	Framer.Device.contentScale = 1
# 1 = MacBook (inc Retina display)
else if unit is 1
	Framer.Device.contentScale = 0.5

# specific ustwo colours
ustwoColours = require "ustwoColours"
# general text styles, colours
styles = require "styles"
# specific animation presets
presets = require "presets"

# make relevant modules global
global = [ustwoColours, styles, presets]
for i in global
	Utils.globalLayers i

# map colours to presets
sluggishFill = piglet
slowFill = honey
smoothFill = ohRa
dynamicFill = pot
snappyFill = blu
blitzFill = mare
customFill = sRain

# default to an independent speed
Framer.Defaults.Animation =
	time: 0.3
	curve: "ease"

# bg layer
bg = new BackgroundLayer
	backgroundColor: nonBlack

# ------------------------------------------------------
# left side
# ------------------------------------------------------
left = new Layer
	width: Screen.width/2, height: Screen.height
	backgroundColor: pot # match first present colour
	
# wrapper for changing left components
leftWrapper = new Layer
	superLayer: left
	size: left.size
	backgroundColor: null
# 	midY: (left.height / 2) + 48 + 18

# -----------------------------
# left side: slider setup
# -----------------------------
# slider sizing to reference later
# sliderWidth = left.width/2
# sliderWidth = left.width * 0.4
sliderSize =
	width: left.width * 0.4
	height: 12
sliderGutter = sliderSize.height * 5
sliderGutter = 24 * 5



# all sliders
sliderCanvas = new Layer
	width: (left.width/2) * 1.4
	height: (sliderSize.height * 14) * 3 + (2 * 24)
	midX: left.width/2, midY: left.midY
	superLayer: leftWrapper
	clip: false
	backgroundColor: null

# -----------------------------
# left side: sliders: spring
# -----------------------------
# array that will store our right page layers
allSliders = []

# loop to make a few sliders
for i in [0..2]
	slider = new SliderComponent
		y: i * (sliderSize.height + sliderGutter)
		width: sliderSize.width
		height: sliderSize.height
		backgroundColor: white20
		knobSize: 48
		min: 0
# 		max: 1, value: 0.5
		pixelAlign: true
		superLayer: sliderCanvas
# 		style: sliderStyle
		midX: sliderCanvas.width/2
	slider.knob.draggable.momentum = false
	slider.fill.backgroundColor = white80
	slider.backgroundColor = black20
	allSliders.push(slider)

# rename for easy access
# "backwards" ordering for less headfuck for user
# see Noah Levin spring diagram
velocity = allSliders[0]
friction = allSliders[1]
tension = allSliders[2]

# adjust maximum values for each,
# make value exactly half as a generic starting point
tension.max = 1000
tension.value = 500

friction.max = 100
friction.value = 50

velocity.max = 100
velocity.value = 50
	
sliderCanvases = []

for i in [0..2]
	sliderPanel = new Layer
		width: sliderCanvas.width
		height: sliderSize.height * 14
		y: i * (sliderSize.height * 14 + 24)
		borderRadius: 8
		superLayer: sliderCanvas
		style: sliderStyle
		backgroundColor: black10
	sliderCanvases.push(sliderPanel)
		
velocitySliderCanvas = sliderCanvases[0]
velocitySliderCanvas.html = "velocity (wind-up)"
velocity.superLayer = velocitySliderCanvas
velocity.midY = velocitySliderCanvas.height/2 + 30
velocity.midX = velocitySliderCanvas.width/2

frictionSliderCanvas = sliderCanvases[1]
frictionSliderCanvas.html = "friction (weight)"
friction.superLayer = frictionSliderCanvas
friction.midY = frictionSliderCanvas.height/2 + 30
friction.midX = frictionSliderCanvas.width/2

tensionSliderCanvas = sliderCanvases[2]
tensionSliderCanvas.html = "tension (bounciness)"
tension.superLayer = tensionSliderCanvas
tension.midY = tensionSliderCanvas.height/2 + 30
tension.midX = tensionSliderCanvas.width/2

sliderBorders = []
for i in [0..2]
	border = new Layer
		width: velocitySliderCanvas.width * 0.9, height: 2
		midX: velocitySliderCanvas.width / 2, y: 69
		backgroundColor: white20
	sliderBorders.push(border)
	
velocitySliderBorder = sliderBorders[0]
velocitySliderBorder.superLayer = velocitySliderCanvas

frictionSliderBorder = sliderBorders[1]
frictionSliderBorder.superLayer = frictionSliderCanvas
	
tensionSliderBorder = sliderBorders[2]
tensionSliderBorder.superLayer = tensionSliderCanvas
# -----------------------------
# images
sliderLabels = []

friction0 = new Layer
	superLayer: frictionSliderCanvas
	width: 79, height: 20
	midY: friction.midY, x: 36
	image: "images/sliders/friction0.png"
friction1 = new Layer
	superLayer: frictionSliderCanvas
	width: 79, height: 25
	midY: friction.midY, maxX: frictionSliderCanvas.width - 36
	image: "images/sliders/friction1.png"

tension0 = new Layer
	superLayer: tensionSliderCanvas
	width: 79, height: 29
	midY: tension.midY, x: 36
	image: "images/sliders/tension0.png"
tension1 = new Layer
	superLayer: tensionSliderCanvas
	width: 79, height: 34
	midY: tension.midY, maxX: tensionSliderCanvas.width - 36
	image: "images/sliders/tension1.png"

velocity0 = new Layer
	superLayer: velocitySliderCanvas
	width: 79, height: 37
	midY: velocity.midY, x: 36
	image: "images/sliders/velocity0.png"
velocity1 = new Layer
	superLayer: velocitySliderCanvas
	width: 79, height: 64
	midY: velocity.midY, maxX: velocitySliderCanvas.width - 36
	image: "images/sliders/velocity1.png"
	
sliderLabels.push(friction0, friction1, tension0, tension1, velocity0, velocity1)

for label in sliderLabels
	label.scale = 0.6
	label.opacity = 0.2

# -----------------------------
# slider logic: spring
# default
springCurve = "spring(#{tension.value}, #{friction.value}, #{velocity.value})"

# custom: dynamic preset (launch preset)
tension.value = dynamicTension
friction.value = dynamicFriction
velocity.value = dynamicVelocity
springCurve = "spring(#{tension.value}, #{friction.value}, #{velocity.value})"

# -----------------------------
# left side: presets (pages)
# -----------------------------
presets = new PageComponent
	midX: sliderCanvas.midX, maxY: sliderCanvas.y - 48
	width: sliderCanvas.width
	height: 100
	scrollVertical: false
	superLayer: leftWrapper

allPresets = []
# Create layers in a for-loop
for i in [0...7]
	preset = new Layer
		superLayer: presets.content
		width: 150
		height: 100
		clip: false
		x: 170 * i
		style: presetStyle
		borderRadius: 6
		opacity: 0.3
	allPresets.push(preset)

sluggish = allPresets[0]
sluggish.html = "sluggish"
sluggish.name = "sluggish"
sluggish.tension = sluggishTension
sluggish.friction = sluggishFriction
sluggish.velocity = sluggishVelocity
sluggish.fill = sluggishFill

slow = allPresets[1]
slow.html = "slow"
slow.name = "slow"
slow.tension = slowTension
slow.friction = slowFriction
slow.velocity = slowVelocity
slow.fill = slowFill

smooth = allPresets[2]
smooth.html = "smooth"
smooth.name = "smooth"
smooth.tension = smoothTension
smooth.friction = smoothFriction
smooth.velocity = smoothVelocity
smooth.fill = smoothFill

dynamic = allPresets[3]
dynamic.html = "dynamic"
dynamic.name = "dynamic"
dynamic.tension = dynamicTension
dynamic.friction = dynamicFriction
dynamic.velocity = dynamicVelocity
dynamic.fill = dynamicFill

snappy = allPresets[4]
snappy.html = "snappy"
snappy.name = "snappy"
snappy.tension = snappyTension
snappy.friction = snappyFriction
snappy.velocity = snappyVelocity
snappy.fill = snappyFill

blitz = allPresets[5]
blitz.html = "blitz"
blitz.name = "blitz"
blitz.tension = blitzTension
blitz.friction = blitzFriction
blitz.velocity = blitzVelocity
blitz.fill = blitzFill

custom = allPresets[6]
custom.html = "custom"
custom.name = "custom"
custom.superLayer = presets.content
# custom.tension = customTension
# custom.friction = customFriction
# custom.velocity = customVelocity
custom.fill = customFill

# staging
presets.snapToPage(allPresets[3], false)
presets.currentPage.opacity = 1


# -----------------------------
# left side: reset, save
# -----------------------------

actionsHolder = new Layer
	width: sliderCanvas.width, height: 150
	superLayer: leftWrapper
	midX: left.width/2, maxY: presets.y - 48
	backgroundColor: null, clip: false
	
reset = new Layer
	superLayer: actionsHolder
	backgroundColor: black10
	html: "reset"
	style: resetStyle
	width: actionsHolder.width/3, height: actionsHolder.height
	
resetImg = new Layer
	superLayer: reset
# 	x: 48
	x: reset.width/5, midY: reset.height/2
	width: 48, height: 43
	image: "images/reset.png"

save = new Layer
	superLayer: actionsHolder
	backgroundColor: black10
	x: reset.maxX + 20
	html: "save"
	style: saveStyle
	width: ((actionsHolder.width/3) * 2 - 20), height: actionsHolder.height
	
saveImg = new Layer
	superLayer: save
	x: save.width/3, midY: save.height/2
	width: 48, height: 43
	image: "images/save.png"
	
actions = [reset, save]
for layer in actions
# 	layer.opacity = 1
	layer.borderRadius = 8
# 	layer.style = actionStyle
	layer.scale = 0.5
	layer.opacity = 0
	
	layer.states.add
		active: scale: 1, opacity: 1
	layer.states.animationOptions =
		time: 0.1
		curve: "ease"
	
saved = new Layer
	superLayer: actionsHolder
	width: actionsHolder.width * 0.75
	midX: actionsHolder.width/2, height: actionsHolder.height
	borderRadius: 8
	backgroundColor: black10
	html: "saved!"
	opacity: 0
	scale: 0.5
	style: savedStyle
savedImg = new Layer
	superLayer: saved
	midY: save.height/2, x: 184
	width: 48, height: 36
	image: "images/saved.png"
		
saved.states.add
	active: scale: 1, opacity: 1
saved.states.animationOptions =
		time: 0.1
		curve: "ease"
	
# -----------------------------
# left side: custom logic save
# -----------------------------	
savedScroll = new ScrollComponent
	width: sliderCanvas.width
	height: left.height * 0.22
	midX: left.width/2, y: left.height + 75
	borderRadius: 8
	backgroundColor: black10
	scrollHorizontal: false
	superLayer: leftWrapper
savedScroll.contentInset =
	top: 20, bottom: 20

savedScroll.content.backgroundColor = null
# savedScroll.html = "No saved interactions yet!"
# savedScroll.style = presetStyle

savedScroll.states.add
	active: y: sliderCanvas.maxY + 48, opacity: 1


# -----------------------------
# left side: wrapper move-about
# -----------------------------	
leftWrapper.states.add
	# spring curves and presets
	spring: midY: sliderCanvas.midY
	springSave: midY: sliderCanvas.midY + actionsHolder.height
	springSaved: midY: sliderCanvas.midY - 24
	
# savedScroll.on Events.StateDidSwitch, ->
# 	leftWrapper.states.switch("springSaved")


# ------------------------------------------------------
# right side: pages, indicators, save
# ------------------------------------------------------
right = new PageComponent
	x: Screen.width/2
	width: Screen.width/2, height: Screen.height
	scrollVertical: false
	backgroundColor: nonBlack
	velocityThreshold: 2
	
right.content.draggable.directionLock = true
# right.content.draggable.directionLockThreshold = {x:205, y:205}

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

# square interactions variables
interactions = []
rows = 2
cols = 2

# make the grid of squares
[0..rows-1].map (a) ->
	[0..cols-1].map (b) ->
		i = new Layer
			size: boundsSize
			x: a * (boundsSize.width + gutter)
			y: b * (boundsSize.height + gutter)
			backgroundColor: white20
			borderRadius: 12
			clip: false
			superLayer: squareCanvas
		# push to array set up above
		interactions.push(i)

# rename these layers to make them handy
scale = interactions[0]
scale.name = "scale"

rotate = interactions[1]
rotate.name = "rotate"

position = interactions[2]
position.name = "position"

opacity = interactions[3]
opacity.name = "opacity"

captions = []
for i in interactions
	caption = new Layer
		superLayer: i
		style: squareStyle
		width: i.width, height: i.height * 0.1
		clip: false, backgroundColor: null
		maxY: i.height * 0.95
		
	captions.push(caption)
	
captions[0].html = interactions[0].name
captions[1].html = interactions[1].name
captions[2].html = interactions[2].name
captions[3].html = interactions[3].name



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
	scale: 0.5, opacity: 0.1
	image: "images/iphone.png"
	superLayer: rightTwo

iphoneCanvas = new Layer
	width: iphone.width * 0.42
	height: iphone.height * 0.37
	backgroundColor: null
	superLayer: rightTwo
	clip: true
iphoneCanvas.center()

card = new Layer
	superLayer: iphoneCanvas
	width: iphoneCanvas.width * 0.9
	height: iphoneCanvas.height * 0.84
	midX: iphoneCanvas.width/2
	y: 100
	borderRadius: 6
	backgroundColor: white
	opacity: 0.5

card.states.add
	second: midX: iphoneCanvas.width * 0.75, scale: 0.66, height: iphoneCanvas.height, midY: (iphoneCanvas.height/2) * 1.05, opacity: 0.2
interactionsTargets.push(card)
	
plus = new Layer
	superLayer: iphoneCanvas
	x: iphoneCanvas.width * 0.058
	y: iphoneCanvas.height * 0.035
	width: 36, height: 36
	image: "images/plus.png"
plus.states.add
	second: rotation: 135, maxX: iphoneCanvas.width * (1-0.058)
interactionsTargets.push(plus)

	
newCards = []	
for newCard in [0..2]
	newCard = new Layer
		superLayer: iphoneCanvas
		width: iphoneCanvas.width * 0.44
		height: iphoneCanvas.height * 0.35
		maxX: - ((iphoneCanvas.width * 0.44) * (newCard) + 75)
		y: newCard * ((iphoneCanvas.height * 0.35) + 50) - 75
		borderRadius: 6
		backgroundColor: white
		opacity: 0.2
		
	newCard.states.add
		second: x: - (iphoneCanvas.width * 0.44) * 0.4, opacity: 0.5
	
	interactionsTargets.push(newCard)	
	newCards.push(newCard)

iphoneCanvas.on Events.Click, ->
	for i in interactionsTargets
		i.states.next()

# -----------------------------
# right side: appleWatch #1
# -----------------------------
appleWatch = new Layer
	width: 593, height: 1014
	image: "images/appleWatch.png"
	midX: rightOne.width/2, midY: rightOne.height/2
	scale: 0.65, opacity: 0.1
	superLayer: rightThree
	
watchCanvas = new Layer
	width: appleWatch.width * 0.4
	height: appleWatch.height * 0.29
	backgroundColor: null
	superLayer: rightThree
	clip: true
watchCanvas.centerY()
watchCanvas.centerX(-10)

notificationCard = new Layer
	superLayer: watchCanvas
	width: watchCanvas.width * 0.9, height: 200
	borderRadius: 10
	backgroundColor: white20
	midX: watchCanvas.width/2, y: watchCanvas.height * 1.1
	
notificationCard.states.add
	first: y: 50
interactionsTargets.push(notificationCard)	

notificationDot = new Layer
	superLayer: watchCanvas
	width: 160, height: 160, borderRadius: "50%"
	backgroundColor: white
	opacity: 0.75
	midX: watchCanvas.width/2, midY: watchCanvas.height * 0.4
	
notificationDot.states.add
	first: scale: 0.45, x: - watchCanvas.width * 0.08, y: - watchCanvas.height * 0.1
interactionsTargets.push(notificationDot)

notificationText = new Layer
	superLayer: watchCanvas
	width: 120, height: 16, borderRadius: 4
	backgroundColor: white, opacity: 0.3
	midX: watchCanvas.width/2, y: notificationDot.maxY + 30
notificationText.states.add
	second: opacity: 0, scale: 0.3, x: 10, y: 60
interactionsTargets.push(notificationText)	
		

watchCanvas.on Events.Click, ->
	for i in interactionsTargets
		i.states.next()

	
# ------------------------------------------------------
# overall functions, settings
# ------------------------------------------------------
# make each in interactionTargets adhere to springCurve
for i in interactionsTargets
	i.states.animationOptions = curve: springCurve

# function for reseting all interactive states
# on page scrolls etc
resetStates = ->
	for i in interactionsTargets
		i.states.switch("default")
		
# function for pushing updates in springCurve (updateCurve function)
pushStates = ->
	for target in interactionsTargets
		# push (assuming) above changes to states
		target.states.animationOptions = curve: springCurve
		# go to next state
		target.states.next()
	
# function for updating springCurve
updateCurve = (preset) ->
# 	update background colour
	left.animate properties: backgroundColor: preset.fill
# 	change values accordingly (to preset)
	tension.animate properties: value: preset.tension
	friction.animate properties: value: preset.friction
	velocity.animate properties: value: preset.velocity
# 	push these to the springCurve
	springCurve = "spring(#{preset.tension}, #{preset.friction}, #{preset.velocity})"
# 	push the new springCurve to the states, and animate
	pushStates()
	for layer in actions
		layer.states.switch("default")
		
	savedScroll.states.switch("default")
		
updateAllCurves = ->
	if presets.currentPage is sluggish
		updateCurve(sluggish)
	else if presets.currentPage is slow
		updateCurve(slow)
	else if presets.currentPage is smooth
		updateCurve(smooth)
	else if presets.currentPage is dynamic
		updateCurve(dynamic)
	else if presets.currentPage is snappy
		updateCurve(snappy)
	else if presets.currentPage is blitz
		updateCurve(blitz)
	else if presets.currentPage is custom
		# update background color
		left.animate properties: backgroundColor: custom.fill
		# show saved custom curves
		savedScroll.states.switch("active")
		# hide reset/save buttons
		for layer in actions
			layer.states.switch("default")
	else # edge-cases, default speed
		updateCurve(dynamic)

# ------------------------------------------------------
# left side: sliders changes, presets changes
# ------------------------------------------------------
# update page on click
for i in allPresets
	i.on Events.Click, ->
		presets.snapToPage(this)
		
# update springCurve when sliders are changed
for i in allSliders
	i.on "change:value", ->
		if this is tension then tension.value = Math.round(tension.value)
		if this is friction then friction.value = Math.round(friction.value)
		if this is velocity then velocity.value = Math.round(velocity.value)

		springCurve = "spring(#{Math.round(tension.value)}, #{Math.round(friction.value)}, #{Math.round(velocity.value)})"
	
	# if th knob has been moved, then custom changes have been made
	i.knob.on Events.DragEnd, ->
		pushStates()
		
		# hide saved! confirmation
		saved.states.switch("default")
		
		for layer in actions
			layer.states.switch("active")


# -----------------------------
# save event
# -----------------------------		
allItems = []
# logic taken from `tasks.framer`
# http://share.framerjs.com/omr7won2119y/
class Item extends Layer
	constructor: (options={}) ->
		options.superLayer ?= savedScroll.content
		options.backgroundColor ?= "rgba(255, 255, 255, 0.8)"
		options.borderRadius ?= 6
		options.width ?= savedScroll.width-40
		options.height ?= 100
		options.x ?= 20
		options.y ?= 0
		options.style = itemStyle
# 		options.springCurve ?= springCurve
		super options
	
save.on Events.TouchStart, ->
	save.animate
		properties: scale: 0.65
		curve: "spring(400, 30, 0)"
save.on Events.TouchEnd, ->
	save.animate
		properties: scale: 1
		curve: "spring(400, 30, 0)"
	
	# Simon's advice for how to acvtually "save" the springCurve
	# 1. save springCurve to an array
	# 2. re-render ScrollComponent
	
	Utils.delay 0.25, ->
		presets.snapToPage(custom)
		# hide save/reset options	
		for layer in actions
			layer.states.switch("default")
		Utils.delay 0.5, ->
			saved.states.switch("active")
		Utils.delay 3, ->
			saved.states.switch("default")
			
			
		# Check if the last item isn't empty
		lastItem = allItems[allItems.length - 1]
		
		newItem = new Item	height: 0
		newItem.index = -allItems.length + 3

		# Start displaying time
		date = new Date()
		h = date.getHours()
		m = date.getMinutes()
		s = date.getSeconds()
		# Set time
		newItem.html = springCurve + " at " + h + ":" + m + ":" + s
		# I'd like the newItem.html to be a combination of words,
		# e.g. for a fast velocity, heavy friction,
		# and a lot of bounciness: 
		# "dyno" + "ball" + "er" = "dynoballer"
		# with enough randomness/range that the same combination
		# isn't save more than once
		newItem.animate
			properties: height: 100
			curve: "spring(400, 30, 0)"
			delay: 0.2
			
		for item in allItems
			item.animate
				properties: y: item.y + 120
				curve: "spring(400, 30, 0)"
				
		allItems.push(newItem)

reset.on Events.TouchStart, ->
	reset.animate
		properties: scale: 0.65
		curve: "spring(400, 30, 0)"
		
reset.on Events.TouchEnd, ->
	reset.animate
		properties: scale: 1
		curve: "spring(400, 30, 0)"
	Utils.delay 0.25, ->
		updateAllCurves()


# -----------------------------
# page change
# -----------------------------			
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
	
	# update curve
	updateAllCurves()

# ------------------------------------------------------
# right side: changes
# ------------------------------------------------------
right.on "change:currentPage", ->
	# Update indicators: remove old
	indicator.states.switch("default") for indicator in rightIndicators
	# Update indicators: update new
	rightCurrent = right.horizontalPageIndex(right.currentPage)
	rightIndicators[rightCurrent].states.switch("active")

	# put back all the squares etc to default state
	resetStates()

# ------------------------------------------------------
# testing
# ------------------------------------------------------
# to test changes in springCurve over time:
# Utils.interval 0.5, ->
# 	print springCurve

