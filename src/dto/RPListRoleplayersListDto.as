import com.Utils.ID32;
import dto.RPListRoleplayerDto;

class dto.RPListRoleplayersListDto
{

	public var roleplayers:Array;

	public function RPListRoleplayersListDto(httpResponseParams:String)
	{
		roleplayers = new Array();
		if (httpResponseParams && httpResponseParams != null)
		{
			parseParams(httpResponseParams);
		}
	}

	private function parseParams(httpResponseParams:String)
	{
		var zoneNameDelimiter:Number = httpResponseParams.indexOf("=");
		var zoneName:String = httpResponseParams.substr(0, zoneNameDelimiter);
		zoneName = unescape(zoneName);
		var delimiterIndex = httpResponseParams.indexOf("&");
		if (delimiterIndex == -1)
		{
			parseRoleplayers(zoneName, httpResponseParams.substr(zoneNameDelimiter + 1), 0);
		}
		else
		{
			parseRoleplayers(zoneName, httpResponseParams.substr(zoneNameDelimiter + 1, delimiterIndex - zoneNameDelimiter - 1), 0);
			parseParams(httpResponseParams.substr(delimiterIndex+1));
		}
	}

	private function parseRoleplayers(zoneName:String, params:String, startIndex:Number)
	{
		var delimiterIndex:Number = params.indexOf(",", startIndex);
		if (delimiterIndex == -1)
		{
			parseRoleplayer(zoneName, params.substr(startIndex));
		}
		else
		{
			parseRoleplayer(zoneName, params.substr(startIndex, delimiterIndex - startIndex));

			parseRoleplayers(zoneName, params, delimiterIndex + 1);
		}
	}

	private function parseRoleplayer(zoneName:String, params:String)
	{
		var roleplayer:RPListRoleplayerDto = new RPListRoleplayerDto();
		roleplayer.zone = zoneName;

		var nameDelimiter:Number = params.indexOf("_");
		roleplayer.id = new ID32(_global.Enums.TypeID.e_Type_GC_Character, Number(params.substr(0, nameDelimiter)));

		var meetupDelimiter:Number = params.indexOf("_", nameDelimiter + 1);
		if (meetupDelimiter == -1)
		{
			roleplayer.nick = unescape(params.substr(nameDelimiter + 1));
		}
		else
		{
			roleplayer.nick = unescape(params.substr(nameDelimiter + 1, meetupDelimiter - nameDelimiter - 1));

			// Future-proofing - in case another flag is added in the future
			var autoMeetupFlag:Number;
			var nextDelimiter:Number = params.indexOf("_", meetupDelimiter + 1);
			if (nextDelimiter == -1)
			{
				roleplayer.autoMeetup = Number(params.substr(meetupDelimiter + 1));
			}
			else
			{
				roleplayer.autoMeetup = Number(params.substr(meetupDelimiter + 1, nextDelimiter - meetupDelimiter - 1));
			}
		}

		roleplayers.push(roleplayer);
	}

}