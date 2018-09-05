EditorLayoutTopdown =
{
	position = {0,0},
	size = {0,0},
	padding = 4,
	items = {},
}

function EditorLayoutTopdown.create( position, width )
	assert( position, "Position was nil." )
	assert( width, "Width was nil." )

	assert( istable( position ), "Position must be a table." )
	assert( isnumber( width ), "Width must be a number." )

	local result = 
	{
		position = tableVal( position ),
		size = { width or 0, 0 },
		items = {}
	}

	setmetatable( result, { __index = EditorLayoutTopdown } )

	return result
end

function EditorLayoutTopdown:addItem( item )
	self.items[#self.items+1] = item

	--NOTE: Room for optimization here
	self:layout()
end

function EditorLayoutTopdown:removeItem( item )
	local index = 0
	for i=1, #self.items do
		if self.items[i] == item then
			index = i
			break
		end
	end

	if index > 0 then
		self.items[index] = nil
	end

	self:layout()
end

function EditorLayoutTopdown:removeAt( index )
	self.items[index] = nil

	self:layout()
end

function EditorLayoutTopdown:layout()
	local xoffset = self.position[1] + self.padding
	local yoffset = self.position[2] + self.padding
	local itemWidth = self.size[1] - self.padding*2

	for i=1, #self.items do
		local position = { xoffset, yoffset }
		self.items[i]:setPosition( position )

		local size = { itemWidth, self.items[i].size[2] }
		if self.items[i].size[1] <= 0 then
			self.items[i]:setSize( size )
		end

		yoffset = yoffset + size[2] + self.padding
	end

	self.size[2] = yoffset
end

function EditorLayoutTopdown:setPosition( position )
	self.position = tableVal( position )
	self:layout()
end

function EditorLayoutTopdown:setSize( size )
	self.size = tableVal( size )
	self:layout()
end

function EditorLayoutTopdown:setPadding( padding )
	self.padding = padding
	self:layout()
end

function EditorLayoutTopdown:call( func, ... )
	for _,v in pairs(self.items) do
		if v[func] then
			v[func]( v, ... )
		end
	end
end