package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class MessageBox
	{
		public var clip : MovieClip;
		private static var lastBox : MessageBox;
		
		public function MessageBox(parent : DisplayObjectContainer, message : String) : void
		{
			if (lastBox != null)
			{
				lastBox.dismiss();
			}
			if (message != "")
			{
				clip = new MessageBoxClip();
				clip.message.text = message;
				clip.OKButton.addEventListener(MouseEvent.CLICK, dismiss);
				parent.addChild(clip);
				lastBox = this;
			}
		}
		
		public function dismiss(e:Event = null):void 
		{
			if (lastBox != null)
			{
				clip.OKButton.removeEventListener(MouseEvent.CLICK, dismiss);
				clip.parent.removeChild(clip);
				lastBox = null;
			}
		}
		
	}

}