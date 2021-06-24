-- SelectInator by UberGoober

-- SelectInator takes a bunch of entities and gives you controls for designating the selected entity and finding it on screen.

-- The selected entity glows, and the glow can be toggled on and off.

-- The SelectionInator also displays an entity's entity.name string, if one has been set.

-- The function 'SelectionInator:doOnSelecting(thisFunction)' allows you to designate an action to perform every time a new entity is selected.

function setup()
      
    --set the scene
    scene = craft.scene()
    scene.ambientColor = color(196, 186, 163)   
    scene.sun.rotation = quat.eulerAngles(140,-160,70)  
    scene.sky.material.horizon = color(60, 134, 150)       
    scene.camera:add(OrbitViewer,vec3(0,0,0),60,0,1000)
            
    --make the entities
    local theseEntities = createEntities()
    
    --add them to the SelectInator, and setup its parameter controls
    selectinator = SelectInator(theseEntities, scene)
    selectinator:watchSelectedName()
    selectinator:createParameters() 
  
    --set a function to call every time selection changes
    selectinator:doOnSelecting(describeCurrentSelection)
end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)   
    scene:draw()    
end

function describeCurrentSelection()
    local current = selectinator:getSelectedEntity()
    local name = current.name or "unnamed entity"
    local entityPosition = "x: "..string.format("%.2f", current.x)..", y: "..string.format("%.2f", current.y)..", z: "..string.format("%.2f", current.z)
    local entityRotation = "x: "..string.format("%.2f", current.eulerAngles.x)..", y: "..string.format("%.2f", current.eulerAngles.y)..", z: "..string.format("%.2f", current.eulerAngles.z)
    print(name.."\n- selected position\n"..entityPosition..
    "\n- eulerAngles\n"..entityRotation)
end


-- a function that creates various emtities and resizes and positions them so they're in a nice little 3 x 3 grid
function createEntities()
    --make some entities 
    local sphere, capsule, monkey, slab, waterShip, spaceShip, dude, palmTree, trebuchet = 
    scene:entity(), scene:entity(), scene:entity(), scene:entity(), scene:entity(), scene:entity(), scene:entity(), scene:entity(), scene:entity()
    
    --add models
    sphere.model, capsule.model, monkey.model, slab.model, waterShip.model, spaceShip.model, dude.model, palmTree.model, trebuchet.model = 
    craft.model("Primitives:Sphere"), craft.model(asset.builtin.Primitives.Capsule), craft.model(asset.builtin.Primitives.Monkey), craft.model(asset.builtin.Primitives.RoundedCube), craft.model(asset.builtin.Watercraft.watercraftPack_003_obj), craft.model(asset.builtin.SpaceKit.spaceCraft6_obj), craft.model(asset.builtin.Blocky_Characters.Soldier), craft.model(asset.builtin.Nature.naturePack_061_obj), craft.model(asset.builtin.CastleKit.siegeTrebuchet_obj)
    
    --give some but not all of them names
    sphere.name, monkey.name, waterShip.name, palmTree.name, trebuchet.name = "sphere", "monkey", "waterShip", "palmTree", "trebuchet"
    
    --put them in a table
    local entities = {sphere, capsule, monkey, slab, waterShip, spaceShip, dude, palmTree, trebuchet}
    
    --position and rotate the entities
    local gridX, gridY = 0, 0
    local offset = vec3(50, 43, 10)
    local index = 1
    for row = 1, 3 do
        gridY = row * -22
        for col = 1, 3 do
            gridX = col * -25
            entities[index].position = vec3(gridX, gridY, 10) + offset
            entities[index].eulerAngles = vec3(10, 165, 0)
            index = index + 1
        end
    end
    --rotate a couple individually
    spaceShip.eulerAngles = vec3(9, -70, 30)
    trebuchet.eulerAngles = vec3(0, 60, -10)
    
    --scale some of them as a group
    local scaleWayUp = vec3(1, 1, 1) * 4.5
    local scaleWayUppers = {sphere, capsule, monkey, waterShip, slab, palmTree}
    for i, entity in ipairs(scaleWayUppers) do
        entity.scale = scaleWayUp
    end
    --scale some individually
    waterShip.scale = vec3(1, 1, 1) * 2.55
    slab.scale = vec3(5, 1.75, 5)
    
    --nudge the position of a few
    slab.position = slab.position + vec3(0, 1.5, 0)
    spaceShip.position = spaceShip.position + vec3(0, 3, 0)
    waterShip.position = waterShip.position + vec3(0, -4.5, 0)
    palmTree.position = palmTree.position + vec3(8.5, -1.5, -9)
    
    --send 'em back!
    return entities
end
