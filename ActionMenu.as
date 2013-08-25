package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class ActionMenu
	{
		private var baseClip : MovieClip;
		private var parent : DisplayObjectContainer;
		private var buttonList : Array;
		private var currentField : Field;
		
		public function ActionMenu(newParent : DisplayObjectContainer) : void
		{
			parent = newParent;
			baseClip = new MovieClip();
			buttonList = [];
			parent.addChild(baseClip);
		}
		
		public function dispose() : void
		{
			destroyMenu();
			currentField = null;
			parent.removeChild(baseClip);
			baseClip = null;
			parent = null;
		}
		
		public function showMenu(field : Field) : void
		{
			destroyMenu();
			currentField = field;
			var actionList : Array = field.getActionList();
			for each (var action : String in actionList)
			{
				addButton(action);
			}
			parent.addChild(baseClip);
			baseClip.y = 340 - baseClip.height;
			var xLoc : int = field.getFieldX() - baseClip.width / 2;
			if (xLoc < 0)
			{
				xLoc = 0;
			}
			if (xLoc + baseClip.width > 624)
			{
				xLoc = 624 - baseClip.width;
			}
			baseClip.x = xLoc;
		}
		
		public function destroyMenu() : void
		{
			for each (var deadButton : MovieClip in buttonList)
			{
				deadButton.removeEventListener(MouseEvent.CLICK, actionButtonPressed);
				baseClip.removeChild(deadButton);
			}
			buttonList = [];
		}
		
		private function addButton(action : String):void
		{
			var newButton : MovieClip = new WoodButton();
			newButton.buttonMode = true;
			newButton.useHandCursor = true;
			newButton.mouseChildren = false;
			newButton.buttonText.text = action;
			newButton.y = (buttonList.length * (newButton.height + 2));
			baseClip.addChild(newButton);
			buttonList.push(newButton);
			newButton.addEventListener(MouseEvent.CLICK, actionButtonPressed);
		}
		
		private function actionButtonPressed(e:MouseEvent):void 
		{
			var button : MovieClip = MovieClip(e.currentTarget);
			var action : String = button.buttonText.text;
			currentField.addAction(action);
			destroyMenu();	
		}
		
	}

}