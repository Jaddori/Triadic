Floor =
{
	position = {-10,0,0},
	orientation = {0,0,0},
	scale = {4,1,2},
	components =
	{
		local Floor_component = ComponentMesh.create( Floor )
		Floor_component:loadMesh( "floor.mesh" )
	}
}
Wall_BottomRight =
{
	position = {15,0,0},
	orientation = {0,0,0},
	scale = {1,1,2},
	components =
	{
		local Wall_BottomRight_component = {
			type = 3,
			minPosition = {9.5,0,-10},
			maxPosition = {10,10,10},
			minOffset = {-5.5,0,-10},
			maxOffset = {-5,10,10}
		}
		local Wall_BottomRight_component = ComponentMesh.create( Wall_BottomRight )
		Wall_BottomRight_component:loadMesh( "wall.mesh" )
	}
}
Wall_TopRight =
{
	position = {-10,0,-15},
	orientation = {0,90,0},
	scale = {1,1,4},
	components =
	{
		local Wall_TopRight_component = {
			type = 3,
			minPosition = {-30,0,-9.5},
			maxPosition = {10,10,-10},
			minOffset = {-20,0,5.5},
			maxOffset = {20,10,5}
		}
		local Wall_TopRight_component = ComponentMesh.create( Wall_TopRight )
		Wall_TopRight_component:loadMesh( "wall.mesh" )
	}
}
Wall_TopLeft =
{
	position = {-35,0,0},
	orientation = {0,180,0},
	scale = {1,1,2},
	components =
	{
		local Wall_TopLeft_component = {
			type = 3,
			minPosition = {-29.5,0,10},
			maxPosition = {-30,10,-10},
			minOffset = {5.5,0,10},
			maxOffset = {5,10,-10}
		}
		local Wall_TopLeft_component = ComponentMesh.create( Wall_TopLeft )
		Wall_TopLeft_component:loadMesh( "wall.mesh" )
	}
}
Wall_BottomLeft =
{
	position = {-10,0,15},
	orientation = {0,270,0},
	scale = {1,1,4},
	components =
	{
		local Wall_BottomLeft_component = {
			type = 3,
			minPosition = {10,0,9.5},
			maxPosition = {-30,10,10},
			minOffset = {20,0,-5.5},
			maxOffset = {-20,10,-5}
		}
		local Wall_BottomLeft_component = ComponentMesh.create( Wall_BottomLeft )
		Wall_BottomLeft_component:loadMesh( "wall.mesh" )
	}
}
Light =
{
	position = {4.21,4.83,-6.95},
	orientation = {0,0,0},
	scale = {1,1,1},
	components =
	{
		local Light_component = ComponentPointLight.create( Light )
		Light_component.position = {4.21,4.83,-6.95}
		Light_component.offset = {0,0,0}
		Light_component.color = {0.6,1,1}
		Light_component.intensity = 4
		Light_component.linear = 1
		Light_component.constant = 1
		Light_component.exponent = 1
		Light_component.size = 1
	}
}
SunLight =
{
	position = {-6.78,16.13,15.48},
	orientation = {0,0,0},
	scale = {1,1,1},
	components =
	{
		local SunLight_component = ComponentDirectionalLight.create( SunLight )
		SunLight_component.direction = {-1,-1,-1}
		SunLight_component.color = {1,0.7,0.7}
		SunLight_component.intensity = 0.1
	}
}
Light2 =
{
	position = {-15.12,5.9,4.42},
	orientation = {0,0,0},
	scale = {1,1,1},
	components =
	{
		local Light2_component = ComponentPointLight.create( Light2 )
		Light2_component.position = {-15.12,5.9,4.42}
		Light2_component.offset = {0,0,0}
		Light2_component.color = {0.6,1,1}
		Light2_component.intensity = 4
		Light2_component.linear = 1
		Light2_component.constant = 1
		Light2_component.exponent = 1
		Light2_component.size = 1
	}
}
Pillar =
{
	position = {-15.46,0,4.35},
	orientation = {0,0,0},
	scale = {1,1,1},
	components =
	{
		local Pillar_component = {
			type = 3,
			minPosition = {-16.46,0,3.35},
			maxPosition = {-14.46,4,5.35},
			minOffset = {-1,0,-1},
			maxOffset = {1,4,1}
		}
		local Pillar_component = ComponentMesh.create( Pillar )
		Pillar_component:loadMesh( "pillar05.mesh" )
	}
}
WalkableSurface =
{
	position = {-30,0,-10},
	orientation = {0,0,0},
	scale = {1,1,1},
	components =
	{
		local WalkableSurface_component = ComponentWalkable.create( WalkableSurface )
		WalkableSurface_component.size = {40,20}
		WalkableSurface_component.interval = 1
	}
}
