local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local deathLog = {}
local blockUntil = 0

local function logAttempt()
    local now = os.clock()
    table.insert(deathLog, now)
    
    local valid = {}
    for i = 1, #deathLog do
        local ts = deathLog[i]
        if now - ts <= 10 then
            table.insert(valid, ts)
        end
    end
    deathLog = valid

    if #deathLog >= 2 then
        blockUntil = now + 10
    end
end

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if key == "Health" or key == "MaxHealth" then
        if typeof(self) == "Instance" and self:IsA("Humanoid") then
            local char = LocalPlayer.Character
            if char and self:IsDescendantOf(char) then
                if key == "Health" and tonumber(value) and value <= 0 then
                    if os.clock() < blockUntil then
                        return
                    end
                    logAttempt()
                elseif key == "MaxHealth" and tonumber(value) and value <= 0 then
                    if os-clock() < blockUntil then
                        return
                    end
                    logAttempt()
                end
            end
        end
    end
    return oldNewIndex(self, key, value)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "TakeDamage" or method == "BreakJoints" or method == "ChangeState" or method == "Destroy" then
        if typeof(self) == "Instance" then
            local char = LocalPlayer.Character
            if char then
                if method == "TakeDamage" and self:IsA("Humanoid") and self:IsDescendantOf(char) then
                    local amount = ...
                    if tonumber(amount) and self.Health - amount <= 0 then
                        if os.clock() < blockUntil then
                            return
                        end
                        logAttempt()
                    end
                elseif method == "BreakJoints" and self:IsA("Model") and self == char then
                    if os.clock() < blockUntil then
                        return
                    end
                    logAttempt()
                elseif method == "ChangeState" and self:IsA("Humanoid") and self:IsDescendantOf(char) then
                    local state = ...
                    if state == Enum.HumanoidStateType.Dead then
                        if os.clock() < blockUntil then
                            return
                        end
                        logAttempt()
                    end
                elseif method == "Destroy" and (self == char or (self:IsA("Humanoid") and self:IsDescendantOf(char))) then
                    if os.clock() < blockUntil then
                        return
                    end
                    logAttempt()
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)
