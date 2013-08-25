package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class PlayerInput
	{
		private var _stage : Stage;
		public var _keyDown : Array;
		
		public function PlayerInput(stage : DisplayObjectContainer) : void
		{
			_keyDown = [];
			for (var i : int = 0; i < 200; i++)
			{
				_keyDown.push (false);
			}
			_stage = stage.stage;
			_stage.focus = _stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			_stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
		}
		
		private function keyPressed(e:KeyboardEvent):void 
		{
			//trace (e.keyCode + " pressed");
			_keyDown[e.keyCode] = true;
			if (e.keyCode == 77) //M
			{
				//SoundManager.muteButtonPressed();
				//SoundManager.musicMuteButtonPressed();
			}
			
		}
		
		private function keyReleased(e:KeyboardEvent):void 
		{
			//trace (e.keyCode + " released");
			_keyDown[e.keyCode] = false;
		}
		
		public function upKey() : Boolean
		{
			return (_keyDown[87] || _keyDown[38]);
		}
		
		public function downKey() : Boolean
		{
			return (_keyDown[83] || _keyDown[40]);
		}
		
		public function leftKey() : Boolean
		{
			var answer : Boolean = false;
			answer = (_keyDown[65] || _keyDown[37]);
			return answer;
		}
		
		public function rightKey() : Boolean
		{
			var answer : Boolean = false;
			answer = (_keyDown[68] || _keyDown[39]);
			return answer;
		}

		public function destroy()
		{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			_stage = null;
			_keyDown = [];
		}
	}

}