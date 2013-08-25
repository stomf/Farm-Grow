package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class AdjustAdvice
	{
		private var clip : MovieClip;
		private var life : int;
		
		public function AdjustAdvice(parent : DisplayObjectContainer, commodity : int, loc : Point, adjustment : int) : void
		{
			if (adjustment != 0)
			{
				var adjustText : String = adjustment.toString();
				if (adjustment < 0)
				{
					//adjustText = "-" + adjustText;
				}
				else
				{
					adjustText = "+" + adjustText;
				}
				
				clip = new adjustIcon();
				clip.mouseChildren = false;
				clip.mouseEnabled = false;
				parent.addChild(clip);
				clip.gotoAndStop(commodity);
				clip.adjust.text = adjustText;
				if (loc.x > 580)
				{
					loc.x = 580;
				}
				clip.x = loc.x;
				clip.y = loc.y;
				life = 120;
				parent.stage.addEventListener(Event.ENTER_FRAME, eachframe);
			}
		}
		
		private function eachframe(e:Event):void 
		{
			if (life % 4 == 0)
			{
				clip.y--;
			}
			life--;
			if (life < 20)
			{
				clip.alpha = (life / 20);
			}
			if (life <= 0)
			{
				destroy();
			}
		}
		
		private function destroy():void
		{
			clip.parent.stage.removeEventListener(Event.ENTER_FRAME, eachframe);
			clip.parent.removeChild(clip);
			clip = null;
		}
		
	}

}