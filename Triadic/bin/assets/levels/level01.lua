New Entity =
{
	position = {1,2,3},
	orientation = {0,0,1,0},
	scale = {1,1,1},
	components =
	{
		Mesh =
		{
			parent = New Entity,
			transform = Transform.create(),
			meshIndex = 3,
		},
	}
}
