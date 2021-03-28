include('shared.lua')

function ENT:Draw()

	if not self or not self:IsValid() then return end

	self:DrawModel()

end
