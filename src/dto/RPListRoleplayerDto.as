import com.Utils.ID32;

class dto.RPListRoleplayerDto
{
	public static var AUTOMEETUP_OFF:Number = 0;
	public static var AUTOMEETUP_ON:Number = 1;
	public static var AUTOMEETUP_UNKNOWN:Number = 2;

	public var id:ID32;
	public var nick:String;
	public var zone:String;
	public var autoMeetup:Number;

	public function RPListRoleplayerDto()
	{
		autoMeetup = AUTOMEETUP_UNKNOWN;
	}

}