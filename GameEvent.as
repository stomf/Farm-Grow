package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class GameEvent extends Event 
	{
		public static const ACTION_BUTTON_PRESSED : String = "Action Button Presssed";
		public static const ACTION_CANCELLED : String = "Action Cancelled";
		public static const JOB_FINISHED : String = "Job Finished";
		public static const GAME_SUSPENDED : String = "Game suspended";
		
		public var arg:*;
		
		public function GameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, ... a:*) : void
		{ 
			super(type, bubbles, cancelable);
			arg = a;
		} 
		
		public override function clone():Event 
		{ 
			return new GameEvent(type, bubbles, cancelable, arg);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("GameEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}