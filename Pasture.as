package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class Pasture
	{
		private var fenceClip : MovieClip;
		public var field : Field;
		public var animalType : int;
		public var animals : int;
		public var timer : int;
		public var destroyed : Boolean;
		
		public static const EMPTY : int = 0;
		public static const PIG : int = 1;
		public static const SHEEP : int = 2;
		public static const COW : int = 3;
		
		public function Pasture(fieldRef : Field) : void
		{
			field = fieldRef;
			fenceClip = new FenceClip();
			field.baseClip.addChild(fenceClip);
			fenceClip.gotoAndStop(1);
			animalType = EMPTY;
			animals = 0;
			timer = 0;
			destroyed = false;
		}
		
		public function dispose() : void
		{
			field = null;
			fenceClip.parent.removeChild(fenceClip);
			destroyed = true;
		}
		
		public function tickField() : void
		{
			if (animals > 1)
			{
				timer++;
				if (timer > 3 * (9 + animalType) && animals < 4)
				{
					//breed
					animals++;
					fenceClip.gotoAndStop((animalType * 4) + animals - 3);
					timer = 0;
				}
			}
			else
			{
				timer = 0;
			}
		}
		
		public function addAnimal(newAnimalType : int) : void
		{
			animals++;
			animalType = newAnimalType;
			//trace ("animalType = " + animalType);
			display();
		}
		
		public function removeAnimal() : void
		{
			animals--;
			if (animals == 0)
			{
				animalType = EMPTY;
				fenceClip.gotoAndStop(1);
			}
			else
			{
				display();
			}
		}
		
		public function display() : void
		{
			fenceClip.gotoAndStop((animalType * 4) + animals - 3);
		}
		
	}

}