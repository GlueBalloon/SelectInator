-- SelectInator by UberGoober

-- SelectInator takes a bunch of entities and gives you controls for designating the selected entity and finding it on screen.

-- The selected entity glows, and the glow can be toggled on and off.

-- The SelectionInator also displays an entity's entity.name string, if one has been set.

-- The function 'SelectionInator:doOnSelecting(thisFunction)' allows you to designate an action to perform every time a new entity is selected.


SelectInator = class()

function SelectInator:init(tableOfEntities, scene)
    assert(tableOfEntities and #tableOfEntities > 0 and scene, "must initialize SelectInator with a table containing at least one entity, and a Craft scene")
    self.scene = scene
    self.entities = tableOfEntities
    self.selectedEntityIndex = 1
    self.highlightMultiplier = 4
    self.selectionAction = function() end
    self:prepareLightingEnvironment(self.scene)
end

function SelectInator:prepareLightingEnvironment(scene) 
    assert(scene, "must call prepareLightingEnvironment with scene parameter")
    local bloom = craft.bloomEffect()
    bloom.intensity = 0.32
    local cameraComponent = scene.camera:get(craft.camera)
    cameraComponent.hdr = true
    cameraComponent.colorTextureEnabled = true 
    cameraComponent:addPostEffect(bloom)
end

function SelectInator:getSelectedEntity()
    return self.entities[self.selectedEntityIndex]
end

function SelectInator:watchSelectedName()
    parameter.text("CurrentlySelectedName") 
end

function SelectInator:createParameters()   
    parameter.integer("SelectedIndex", 1, #self.entities, 1, function(value)
        self:setSelectedByIndex(value)
    end)
    
    parameter.action("Select Next Entity", function()
        if self.selectedEntityIndex == #self.entities then
            self:setSelectedByIndex(1)
        else
            self:setSelectedByIndex(self.selectedEntityIndex + 1)
        end
    end)
    
    parameter.action("Select Previous Entity", function()
        if self.selectedEntityIndex == 1 then
            self:setSelectedByIndex(#self.entities)
        else
            self:setSelectedByIndex(self.selectedEntityIndex - 1)
        end
    end)
    
    parameter.boolean("HighlightOn", false, function(value)   
        self:setHighlightOn(value)
    end)
    
    self:setSelectedByIndex(self.selectedEntityIndex)
    self:setHighlightState(self:getSelectedEntity(), true)
end

function SelectInator:setHighlightOn(value)
    HighlightOn = value
    self:setHighlightState(self:getSelectedEntity(), value)
end

function SelectInator:setSelected(entityToSelect)
    for i, thisEntity in ipairs(self.entities) do
        if thisEntity == entityToSelect then
            self:setSelectedByIndex(i)
            return
        end
    end
end

function SelectInator:setSelectedByIndex(index)
    local oldBaby = self:getSelectedEntity()
    self.selectedEntityIndex = index
    SelectedIndex = index
    local newBaby = self:getSelectedEntity()
    if newBaby.name then
        CurrentlySelectedName = newBaby.name
    else
        CurrentlySelectedName = "entity.name not set"
    end
    self:setHighlightState(newBaby, true)
    self:setHighlightState(oldBaby, false)
    HighlightOn = true
    self.selectionAction()
end

function SelectInator:setHighlightState(thisEntity, stateToSet)
    if thisEntity.isSelected == nil and stateToSet == false then
        thisEntity.isSelected = false
        return
    elseif thisEntity.isSelected == stateToSet then
        return
    end  
    if stateToSet then 
        self:applyDiffuseMultiplier(self.highlightMultiplier, thisEntity) --highlight entity
    else
        self:applyDiffuseMultiplier(1/self.highlightMultiplier, thisEntity) --de-highlight entity
    end
    thisEntity.isSelected = stateToSet
end

function SelectInator:applyDiffuseMultiplier(multiplier, entity)
    if not entity.model then return end
    local numberOfSubmeshes, thisMaterial
    numberOfSubmeshes = entity.model.submeshCount
    for i=1, numberOfSubmeshes do
        thisMaterial = entity.model:getMaterial(i)
        thisMaterial.diffuse = thisMaterial.diffuse*multiplier
    end
    if entity.material and entity.material.diffuse then
        entity.material.diffuse = entity.material.diffuse * multiplier
    end
end

function SelectInator:doOnSelecting(thisFunction)
    self.selectionAction = thisFunction
end
