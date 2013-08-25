package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class Research
	{
		//singleton class
		public static var ref : Research;
		
		public var productivity : int;
		public var infrastructure : int;
		public var enlightenment : int;
		
		private var clip : MovieClip;
		private var store : Store;
		private var parent : DisplayObjectContainer;
		
		private var prodCost : int;
		private var infCost : int;
		private var enlCost : int;
		
		public function Research(parentRef : DisplayObjectContainer, storeRef : Store) : void
		{
			ref = this;
			parent = parentRef;
			store = storeRef;
			productivity = 1;
			infrastructure = 1;
			enlightenment = 1;
			//trace ('xheck');
			clip = new ResearchBoardClip();
			parent.addChild(clip);
			clip.visible = false;
			updateBoard();
			clip.doneButton.addEventListener(MouseEvent.CLICK, doneButtonPressed);
			clip.prod.base.buyButton.addEventListener(MouseEvent.CLICK, buyProd);
			clip.infra.base.buyButton.addEventListener(MouseEvent.CLICK, buyInf);
			clip.enl.base.buyButton.addEventListener(MouseEvent.CLICK, buyEnl);
		}
		
		public static function dispose() : void
		{
			ref.hiddenDispose();
		}
		
		public function hiddenDispose() : void
		{
			clip.doneButton.removeEventListener(MouseEvent.CLICK, doneButtonPressed);
			clip.prod.base.buyButton.removeEventListener(MouseEvent.CLICK, buyProd);
			clip.infra.base.buyButton.removeEventListener(MouseEvent.CLICK, buyInf);
			clip.enl.base.buyButton.removeEventListener(MouseEvent.CLICK, buyEnl);
			parent.removeChild(clip);
			clip = null;
			parent = null;
			store = null;
			ref = null;
		}
		
		public function techPercent() : int
		{
			var total : int = productivity + infrastructure + enlightenment - 3;
			return Math.round(100 * total / 18);
		}
		
		private static function updateBoard() : void
		{
			ref.clip.prod.gotoAndStop(ref.productivity);
			ref.clip.infra.gotoAndStop(ref.infrastructure);
			ref.clip.enl.gotoAndStop(ref.enlightenment);
			ref.prodCost = int(ref.clip.prod.cost.text);
			ref.enlCost = int (ref.clip.enl.cost.text);
			ref.infCost = int (ref.clip.infra.cost.text);
			ref.clip.currency.text = ref.store.resource[Store.KNOWLEDGE].toString();
			ref.clip.tutorialText.visible = (ref.store.resource[Store.KNOWLEDGE] == 0);
		}
		
		private function buyProd(e:MouseEvent):void 
		{
			if (ref.store.resource[Store.KNOWLEDGE] >= ref.prodCost)
			{
				ref.productivity++;
				ref.store.adjustStores(Store.KNOWLEDGE, -ref.prodCost, new Point (216, 300));
			}
			updateBoard();
		}
		
		private function buyInf(e:MouseEvent):void 
		{
			if (ref.store.resource[Store.KNOWLEDGE] >= ref.infCost)
			{
				ref.infrastructure++;
				ref.store.adjustStores(Store.KNOWLEDGE, -ref.infCost, new Point (216, 300));
			}
			updateBoard();
		}
		
		private function buyEnl(e:MouseEvent):void 
		{
			if (ref.store.resource[Store.KNOWLEDGE] >= ref.enlCost)
			{
				ref.enlightenment++;
				ref.store.adjustStores(Store.KNOWLEDGE, -ref.enlCost, new Point (216, 300));
			}
			updateBoard();
		}
		
		private function doneButtonPressed(e:MouseEvent):void 
		{
			clip.visible = false;
		}
		
		public static function showResearch() : void
		{
			ref.clip.visible = true;
			updateBoard();
			//trace (ref.prodCost, ref.enlCost, ref.infCost, ref.store.resource[Store.KNOWLEDGE]);
			ref.clip.screenP.visible = !(ref.store.resource[Store.KNOWLEDGE] >= ref.prodCost);
			ref.clip.screenI.visible = !(ref.store.resource[Store.KNOWLEDGE] >= ref.infCost);
			ref.clip.screenE.visible = !(ref.store.resource[Store.KNOWLEDGE] >= ref.enlCost);
			
		}
		
		
	}

}