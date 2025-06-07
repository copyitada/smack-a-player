local module = {}

--[[
	Lettuce's Craters V1
	2/20/25
	im gonna add more to this js be patient 😭💔💔
	///
	
	
	Arguments (crater)
	position:CFrame - Origin/Center of the crater
	radius:number - The radius of the rocks around the origin
	minAmount:number - The minimum amount of rocks to make
	maxAmount:number - The maximum amount of rocks to make
	minSize:Vector3 - The minimum size a rock can be
	maxSize:Vector3 - The maximum size a rock can be
	maximumYDistance:number - The maximum amount of studs we can raycast down
	explode:boolean - Do we want explosion fx from the rocks?
	decayMin:number - Minimum amount of time for the rocks to despawn
	decayMax:number - Maximum amount of time for the rocks to despawn
	angleOffset:number - Optional, but applies the angle 
	
	
	Arguments (crater rows)
	
	startRadius:number - The radius we want to start the rows at (because it may increase)
	radiusIncrease:number - Increase the radius by a certain number every new row (Negative numbers work)
	sizeDecreasePerRow:Vector3 - Decrease the size every new row (Negative numbers work)
	decreaseAmountPerRow:number - Decrease the minimum and maximum number of rocks per row
	
]]

module.config = {
	debrisFolder = game.Workspace.VFX.Debris; --// Debris folder to store parts in
	whitelist = game.Workspace.Geometry; --// Where we can place rocks
}

local tweenService = game:GetService("TweenService")

local function rndsd()return math.randomseed(math.random(1,50^2))end--random seed
local function rnd(min,max)return Random.new(rndsd()):NextInteger(min,max)end--random number (min-max)
local function rndw()return Random.new(rndsd()):NextNumber()end--random number (0-1)
local function rndS(n)return if math.random(1,2)==1 then n*-1 else n end--random sign

-- UNUSED!!!!!!
local function lerp(a,b,t)return a*(1-t)+(b*t)end
local function quadBezier(a,b,c,t)return lerp(lerp(a,b,t),lerp(b,c,t),t)end
local function cubicBezier(a,b,c,d,t)return lerp(lerp(a,b,t),lerp(b,c,t),lerp(c,d,t))end

function module.Crater(position:CFrame,radius:number,minAmount:number,maxAmount:number,minSize:Vector3,maxSize:Vector3,maximumYDistance:number,explode:boolean,decayMin:number,decayMax:number,angleOffset:number)
	local Amount = math.random(minAmount,maxAmount)
	angleOffset = angleOffset or 0
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {module.config.whitelist}
	Params.RespectCanCollide = true
	Params.IgnoreWater = true

	local angle = angleOffset
	for i = 1,Amount do

		local CurrentCF = position * CFrame.fromEulerAnglesXYZ(0,math.rad(angle),0) * CFrame.new(radius,0,0)
		local ray = workspace:Raycast(CurrentCF.Position,Vector3.new(0,-maximumYDistance,0),Params)

		if ray and ray.Instance then
			local rock = Instance.new("Part",module.config.debrisFolder)

			local sx = rnd(minSize.X,maxSize.X)
			local sy = rnd(minSize.Y,maxSize.Y)
			local sz = rnd(minSize.Z,maxSize.Z)
			local twt = rndw()/6
			rock.Size = Vector3.new(sx,sy,sz)
			rock.Position = ray.Position-Vector3.new(0,rnd(3,6),0)
			rock.Color = ray.Instance.Color
			rock.Material = ray.Instance.Material
			rock.CFrame = CFrame.lookAt(rock.CFrame.Position, position.Position)
			rock.CFrame = rock.CFrame*CFrame.Angles(math.rad(220),0,0)

			rock.Anchored = true

			local stween = tweenService:Create(rock,TweenInfo.new(twt,Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut),{Position=ray.Position})
			stween:Play()

			stween.Completed:Once(function()
				if explode and math.random(1,3)==1 then
					local a = math.random(minAmount,maxAmount)

					for i = 1, a do
						local CurrentCF = rock.CFrame
						local size = rnd(1,1.2)
						local erock = Instance.new("Part",module.config.debrisFolder)
						erock.CollisionGroup = "noTouch"
						erock.Anchored = false
						erock.Color = ray.Instance.Color
						erock.Material = ray.Instance.Material
						erock.Size = Vector3.new(size,size,size)
						erock.Position = rock.Position+Vector3.new(0,1,0)

						local p1 = rndS(rndw()/4)
						local p2 = rndS(rndw()/4)

						erock:ApplyImpulse((erock.CFrame.UpVector+Vector3.new(p1,rndw()/4,p2))*(erock.AssemblyMass*130))
						erock:ApplyAngularImpulse(Vector3.new(rnd(0,360),rnd(0,360),rnd(0,360)))
						task.delay(decayMin+decayMax,function()
							tweenService:Create(erock,TweenInfo.new(rnd(decayMin,decayMax)),{Transparency=1,Size=Vector3.new(0,0,0)}):Play()
							game:GetService("Debris"):AddItem(erock,decayMax+decayMin)
						end)

					end

				end
			end)

			task.delay(twt+rnd(decayMin,decayMax),function()
				tweenService:Create(rock,TweenInfo.new(rnd(decayMin,decayMax)),{Position=ray.Position-Vector3.new(0,9,0)}):Play()
				game:GetService("Debris"):AddItem(rock,decayMax+.05)
			end)
		end

		angle+= 360 / Amount
	end

end

function module.CraterRows(position:CFrame,rows:number,startRadius:number,radiusIncrease:number,sizeDecreasePerRow:Vector3,decreaseAmountPerRow:number,minAmount:number,maxAmount:number,minSize:Vector3,maxSize:Vector3,maximumYDistance:number,explode:boolean,decayMin:number,decayMax:number)
	local currentRadius = startRadius
	local min = minAmount
	local max = maxAmount
	local s_min = minSize
	local s_max = maxSize
	
	for i = 1, rows do
		module.Crater(position,currentRadius,min,max,s_min,s_max,maximumYDistance,explode,decayMin,decayMax,math.random(1,360))
		currentRadius+=radiusIncrease
		min-=decreaseAmountPerRow
		max-=decreaseAmountPerRow
		s_min-=sizeDecreasePerRow
		s_max-=sizeDecreasePerRow
	end
end



return module
