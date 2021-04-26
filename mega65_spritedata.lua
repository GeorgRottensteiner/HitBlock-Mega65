W,H = GetImageSize();

local tileSize = 16;

WX = W / tileSize;
WY = H / 21;

local img = GetImage( 0, 0, W, H );    

for j = 0, WY - 1 do
  for i = 0, WX - 1 do
    _ALERT( "!realign 256" );
    _ALERT( "          ;sprite " .. ( i * tileSize ) .. ", " .. ( j * tileSize ) );
    for l = 0, 21 - 1 do
      local lineText = "        !byte ";
      for k = 0, tileSize - 1,2 do
        local curPixelValue = img:GetPixel( i * tileSize + k, j * tileSize + l );
        curPixelValue = curPixelValue * 16;
        curPixelValue = curPixelValue + img:GetPixel( i * tileSize + k + 1, j * tileSize + l );
        lineText = lineText .. curPixelValue;
        if ( k < tileSize - 2 ) then
          lineText = lineText .. ",";
        end
      end
      _ALERT( lineText );
    end
  end
end