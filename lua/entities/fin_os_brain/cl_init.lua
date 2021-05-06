include('shared.lua')

function ENT:Draw()

	if not self or not self:IsValid() then return end

	if GetConVar("finos_cl_enableHoverRingBall_fin"):GetInt() == 1 then self:DrawModel() end

end
