$lines = [System.IO.File]::ReadAllLines( $args[0] );

$numStages = $lines.Length / 2;

$stageNames = @();
$stageDatas = @();

for ( $s = 0; $s -lt $numStages; ++$s )
{
  $stageName = $lines[$s * 2].Trim();
  $stageData = $lines[$s * 2 + 1].Trim();

  $stageNames += "MAP_" + $s.ToString();

  $data = "";

  $stageData = $stageData.Substring( 6, $stageData.Length - 6 - 1 );
  
  if ( $stageData.length -ne 480 )
  {
    throw ( "Stage " + $stageName + ", Nr. " + $s.ToString() + " is malformed" )
  }

  $prevByte = -1;
  $equCount = 0;
  for ( $b = 0; $b -lt 240; ++$b )
  {
    $byteHex = "0x" + $stageData.Substring( $b * 2, 2 )
    $byte = [int]$byteHex;
    
    if ( $byte -ne $prevByte )
    {
      if ( $prevByte -ge 0 )
      {
        if ( $equCount -gt 1 )
        {
          # rle
          $data += ( $equCount + 0x80 ).ToString( "X2" );
          $data += $prevByte.ToString( "X2" );
        }
        else
        {
          $data += $prevByte.ToString( "X2" );
        }
      }
      $prevByte = $byte;
      $equCount = 1;
    }
    else
    {
      ++$equCount;
    }
  }
  if ( $equCount -gt 1 )
  {
    $data += ( $equCount + 0x80 ).ToString( "X2" );
    $data += $prevByte.ToString( "X2" );
  }
  else
  {
    $data += $prevByte.ToString( "X2" );
  }
  
  $stageDatas += $data;
  #echo ( $stageName )
  #echo ( "          !hex """ + $data + """" )
}

$maxStages = $stageNames.Count;

echo ( "MAX_STAGE_COUNT = " + $maxStages )
echo "`n"

echo ( "MAPS_LO" )
for ( $s = 0; $s -lt $stageNames.Length; ++$s )
{
  echo( "          !byte <" + $stageNames[$s] );
}
echo "`n"

echo ( "MAPS_HI" )
for ( $s = 0; $s -lt $stageNames.Length; ++$s )
{
  echo( "          !byte >" + $stageNames[$s] );
}
echo "`n"

for ( $s = 0; $s -lt $stageNames.Count; ++$s )
{
  echo ( $stageNames[$s] )
  echo ( "          !hex """ + $stageDatas[$s] + """" )
}