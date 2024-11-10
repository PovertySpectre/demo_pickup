AddCSLuaFile()

SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/v_portalgun.mdl"
SWEP.WorldModel = "models/weapons/w_portalgun.mdl"
SWEP.ViewModelFOV = GetConVar("viewmodel_fov")

SWEP.Weight = 4

SWEP.Primary.Ammo = "portalgun"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true

game.AddParticles("particles/portalgun.pcf")

sound.Add({
	sound = "player/object_use_stop_01.wav",
	name = "PortalPlayer.ObjectUseStop",
	channel = CHAN_ITEM,
	level = 75,
	volume = 0.5
})

sound.Add({
	sound = "player/object_use_lp_01.wav",
	name = "PortalPlayer.ObjectUse",
	channel = CHAN_ITEM,
	level = 75,
	volume = 0.8
})

function SWEP:SetupDataTables()

	self:NetworkVar("Bool", 1, "CarryingObject")
	self:NetworkVar("Bool", 0, "FirstDeploy")

	if SERVER then
		self:SetFirstDeploy(true)
	end

end

function SWEP:Initialize()

	self:SetHoldType("shotgun")

	timer.Create(self:GetClass() .. "_" .. self:EntIndex(), 0, 0, function()
		self:RemoveEffects(EF_NODRAW)
	end)

end

local sv_defaultdeployspeed = GetConVar("sv_defaultdeployspeed")

function SWEP:Deploy()

	if CLIENT then return end

	local owner = self:GetOwner()
	if owner:IsValid() then
		if owner:IsPlayer() then
			local vm = owner:GetViewModel()
			if vm:IsValid() then
				vm:SetWeaponModel(self:GetWeaponViewModel(), NULL)
				local vm1 = owner:GetViewModel(1)
				if vm1:IsValid() then
					vm1:SetWeaponModel(self:GetWeaponViewModel(), self)
					if self:GetCarryingObject() then
						vm1:SendViewModelMatchingSequence(vm1:SelectWeightedSequence(ACT_VM_RELEASE))
						owner:StopSound("PortalPlayer.ObjectUse")
						owner:EmitSound("PortalPlayer.ObjectUseStop")
					elseif self:GetFirstDeploy() then
						vm1:SendViewModelMatchingSequence(vm1:SelectWeightedSequence(ACT_VM_DRAW))
						vm1:SetPlaybackRate(sv_defaultdeployspeed:GetFloat())
						self:SetFirstDeploy(false)
					end
				end
				
			end
		end
	end

	return true

end

function SWEP:Holster(wep)

	if CLIENT then return end

	local owner = self:GetOwner()
	if owner:IsValid() then
		if owner:IsPlayer() then
			local vm1 = owner:GetViewModel(1)
			if vm1:IsValid() then
				if wep:IsValid() then
					vm1:SendViewModelMatchingSequence(vm1:SelectWeightedSequence(ACT_VM_DRAW))
					vm1:SetPlaybackRate(sv_defaultdeployspeed:GetFloat())
					vm1:SetWeaponModel(self:GetWeaponViewModel(), NULL)
					self:SetCarryingObject(false)
					owner:StopSound("PortalPlayer.ObjectUse")
				else
					vm1:SendViewModelMatchingSequence(vm1:SelectWeightedSequence(ACT_VM_PICKUP))
					self:SetCarryingObject(true)
					if owner:Alive() then
						owner:EmitSound("PortalPlayer.ObjectUse")
					end
				end
			end
		end
	end

	return true

end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:OnRemove()
	timer.Remove(self:GetClass() .. "_" .. self:EntIndex())
end