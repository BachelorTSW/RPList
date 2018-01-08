import com.Utils.ID32;
import dto.RPListRoleplayerDto;

class dto.RPListRoleplayersListDto
{

	public var roleplayers:Array;

	public function RPListRoleplayersListDto(httpResponseParams:String)
	{
		roleplayers = new Array();
		parseParams(httpResponseParams, 0);
	}

	private function parseParams(httpResponseParams:String, startIndex:Number)
	{
		var zoneNameDelimiter:Number = httpResponseParams.indexOf("=");
		var zoneName:String = httpResponseParams.substr(startIndex, zoneNameDelimiter - startIndex);
		zoneName = unescape(zoneName);
		var delimiterIndex = httpResponseParams.indexOf("&", startIndex);
		if (delimiterIndex == -1)
		{
			parseIds(zoneName, httpResponseParams.substr(zoneNameDelimiter + 1), 0);
		}
		else
		{
			parseIds(zoneName, httpResponseParams.substr(zoneNameDelimiter + 1, delimiterIndex - zoneNameDelimiter - 1));
			parseParams(httpResponseParams, delimiterIndex + 1);
		}
	}

	private function parseIds(zoneName:String, params:String, startIndex:Number)
	{
		var roleplayer:RPListRoleplayerDto = new RPListRoleplayerDto();
		roleplayer.zone = zoneName;

		var delimiterIndex:Number = params.indexOf(",", startIndex);
		var idString:String;
		if (delimiterIndex == -1)
		{
			idString = params.substr(startIndex);
			roleplayer.id = new ID32(_global.Enums.TypeID.e_Type_GC_Character, Number(idString));
			roleplayers.push(roleplayer);
		}
		else
		{
			idString = params.substr(startIndex, delimiterIndex - startIndex);
			roleplayer.id = new ID32(_global.Enums.TypeID.e_Type_GC_Character, Number(idString));
			roleplayers.push(roleplayer);
			parseIds(zoneName, params, delimiterIndex + 1);
		}
	}

}