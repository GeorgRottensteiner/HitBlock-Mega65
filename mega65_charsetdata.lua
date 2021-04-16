W,H = GetImageSize();

local tileSize = 8;

WX = W / tileSize;
WY = H / tileSize;

local img = GetImage( 0, 0, W, H );    

for j = 0, WY - 1 do
  for i = 0, WX - 1 do
    _ALERT( ";tile " .. ( i * tileSize ) .. ", " .. ( j * tileSize ) );
    for l = 0, tileSize - 1 do
      local lineText = "        !byte ";
      for k = 0, tileSize - 1 do
        lineText = lineText .. img:GetPixel( i * tileSize + k, j * tileSize + l );
        if ( k < tileSize - 1 ) then
          lineText = lineText .. ",";
        end
      end
      _ALERT( lineText );
    end
  end
end