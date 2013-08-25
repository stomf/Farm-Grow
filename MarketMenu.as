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
	public class MarketMenu
	{
		private var store : Store;
		private var clip : MovieClip;
		
		private var buyPrices : Array;
		private var sellPrices : Array;
		private var available : Array;
		
		private var animalChoice : int;
		public static const animalNames : Array = ["Empty", "Pig", "Sheep", "Cow"];
		
		public function MarketMenu(parent : DisplayObjectContainer, storeRef : Store) : void
		{
			store = storeRef;
			clip = new MarketClip();
			parent.addChild(clip);
			setPrices();
			displayData();
			addEventListeners();
		}
		
		private function addEventListeners():void
		{
			clip.buyGrainButton.addEventListener(MouseEvent.CLICK, buyGrain);
			clip.buyFlourButton.addEventListener(MouseEvent.CLICK, buyFlour);
			clip.buyBreadButton.addEventListener(MouseEvent.CLICK, buyBread);
			clip.buyVegButton.addEventListener(MouseEvent.CLICK, buyVeg);
			clip.buyMeatButton.addEventListener(MouseEvent.CLICK, buyMeat);
			clip.buyWoodButton.addEventListener(MouseEvent.CLICK, buyWood);
			
			clip.sellGrainButton.addEventListener(MouseEvent.CLICK, sellGrain);
			clip.sellFlourButton.addEventListener(MouseEvent.CLICK, sellFlour);
			clip.sellBreadButton.addEventListener(MouseEvent.CLICK, sellBread);
			clip.sellVegButton.addEventListener(MouseEvent.CLICK, sellVeg);
			clip.sellMeatButton.addEventListener(MouseEvent.CLICK, sellMeat);
			clip.sellWoodButton.addEventListener(MouseEvent.CLICK, sellWood);
			
			clip.buyAnimalButton.addEventListener(MouseEvent.CLICK, buyAnimal);
			
			clip.doneButton.addEventListener(MouseEvent.CLICK, finishTrading);
		}
		
		private function removeEventListeners():void
		{
			clip.buyGrainButton.removeEventListener(MouseEvent.CLICK, buyGrain);
			clip.buyFlourButton.removeEventListener(MouseEvent.CLICK, buyFlour);
			clip.buyBreadButton.removeEventListener(MouseEvent.CLICK, buyBread);
			clip.buyVegButton.removeEventListener(MouseEvent.CLICK, buyVeg);
			clip.buyMeatButton.removeEventListener(MouseEvent.CLICK, buyMeat);
			clip.buyWoodButton.removeEventListener(MouseEvent.CLICK, buyWood);
			
			clip.sellGrainButton.removeEventListener(MouseEvent.CLICK, sellGrain);
			clip.sellFlourButton.removeEventListener(MouseEvent.CLICK, sellFlour);
			clip.sellBreadButton.removeEventListener(MouseEvent.CLICK, sellBread);
			clip.sellVegButton.removeEventListener(MouseEvent.CLICK, sellVeg);
			clip.sellMeatButton.removeEventListener(MouseEvent.CLICK, sellMeat);
			clip.sellWoodButton.removeEventListener(MouseEvent.CLICK, sellWood);
			
			clip.buyAnimalButton.removeEventListener(MouseEvent.CLICK, buyAnimal);
			
			clip.doneButton.removeEventListener(MouseEvent.CLICK, finishTrading);
		}
		
		private function finishTrading(e:MouseEvent = null):void 
		{
			removeEventListeners();
			store = null;
			clip.parent.removeChild(clip);
			clip = null;
			buyPrices = [];
			sellPrices = [];
			available = [];
		}
		
		public function dispose() : void
		{
			if (store != null)
			{
				finishTrading();
			}
		}
		
		private function attemptPurchase(commodity : int, shiftKeyDown : Boolean) : void
		{
			if (shiftKeyDown)
			{
				if (store.resource[Store.GOLD] >= buyPrices[commodity] * 10 && available[commodity] > 9)
				{
					store.adjustStores(Store.GOLD, -buyPrices[commodity] * 10, new Point(624, 320));
					store.adjustStores(commodity, 10, new Point(624, 300));
					available[commodity] -= 10;
					displayData();
				}
			}
			else 
			{
				if (store.resource[Store.GOLD] >= buyPrices[commodity] && available[commodity] > 0)
				{
					store.adjustStores(Store.GOLD, -buyPrices[commodity], new Point(624, 320));
					store.adjustStores(commodity, 1, new Point(624, 300));
					available[commodity] -= 1;
					displayData();
				}
			}
		}
		
		private function buyGrain(e:MouseEvent):void 
		{
			attemptPurchase(Store.GRAIN, e.shiftKey);
		}
		
		private function buyFlour(e:MouseEvent):void 
		{
			attemptPurchase(Store.FLOUR, e.shiftKey);
		}
		
		private function buyBread(e:MouseEvent):void 
		{
			attemptPurchase(Store.BREAD, e.shiftKey);
		}
		
		private function buyVeg(e:MouseEvent):void 
		{
			attemptPurchase(Store.VEG, e.shiftKey);
		}
		
		private function buyMeat(e:MouseEvent):void 
		{
			attemptPurchase(Store.MEAT, e.shiftKey);
		}
		
		private function buyWood(e:MouseEvent):void 
		{
			attemptPurchase(Store.WOOD, e.shiftKey);
		}
		
		private function attemptSell(commodity : int, shiftKeyDown : Boolean) : void
		{
			if (shiftKeyDown)
			{
				if (store.resource[commodity] > 9)
				{
					store.adjustStores(Store.GOLD, sellPrices[commodity] * 10, new Point(624, 300));
					available[commodity] += 10;
					store.adjustStores(commodity, -10, new Point(624, 320));
					displayData();
				}
			}
			else
			{
				if (store.resource[commodity] > 0)
				{
					store.adjustStores(Store.GOLD, sellPrices[commodity], new Point(624, 300));
					available[commodity] += 1;
					store.adjustStores(commodity, -1, new Point(624, 320));
					displayData();
				}
			}
		}
		
		private function sellGrain(e:MouseEvent):void 
		{
			attemptSell(Store.GRAIN, e.shiftKey);
		}
		
		private function sellFlour(e:MouseEvent):void 
		{
			attemptSell(Store.FLOUR, e.shiftKey);
		}
		
		private function sellBread(e:MouseEvent):void 
		{
			attemptSell(Store.BREAD, e.shiftKey);
		}
		
		private function sellVeg(e:MouseEvent):void 
		{
			attemptSell(Store.VEG, e.shiftKey);
		}
		
		private function sellMeat(e:MouseEvent):void 
		{
			attemptSell(Store.MEAT, e.shiftKey);
		}
		
		private function sellWood(e:MouseEvent):void 
		{
			attemptSell(Store.WOOD, e.shiftKey);
		}
		
		private function displayData():void
		{
			clip.gold.text = store.resource[Store.GOLD].toString();
			clip.grainOwned.text = store.resource[Store.GRAIN].toString();
			clip.flourOwned.text = store.resource[Store.FLOUR].toString();
			clip.breadOwned.text = store.resource[Store.BREAD].toString();
			clip.vegOwned.text = store.resource[Store.VEG].toString();
			clip.meatOwned.text = store.resource[Store.MEAT].toString();
			clip.woodOwned.text = store.resource[Store.WOOD].toString();
			
			clip.grainSellPrice.text = sellPrices[Store.GRAIN].toString();
			clip.flourSellPrice.text = sellPrices[Store.FLOUR].toString();
			clip.breadSellPrice.text = sellPrices[Store.BREAD].toString();
			clip.vegSellPrice.text = sellPrices[Store.VEG].toString();
			clip.meatSellPrice.text = sellPrices[Store.MEAT].toString();
			clip.woodSellPrice.text = sellPrices[Store.WOOD].toString();
			
			clip.grainBuyPrice.text = buyPrices[Store.GRAIN].toString();
			clip.flourBuyPrice.text = buyPrices[Store.FLOUR].toString();
			clip.breadBuyPrice.text = buyPrices[Store.BREAD].toString();
			clip.vegBuyPrice.text = buyPrices[Store.VEG].toString();
			clip.meatBuyPrice.text = buyPrices[Store.MEAT].toString();
			clip.woodBuyPrice.text = buyPrices[Store.WOOD].toString();
			
			clip.grainAvailable.text = available[Store.GRAIN].toString();
			clip.flourAvailable.text = available[Store.FLOUR].toString();
			clip.breadAvailable.text = available[Store.BREAD].toString();
			clip.vegAvailable.text = available[Store.VEG].toString();
			clip.meatAvailable.text = available[Store.MEAT].toString();
			clip.woodAvailable.text = available[Store.WOOD].toString();
			
			clip.animalAvailable.text = available[Store.ANIMAL].toString();
			clip.animalBuyPrice.text = buyPrices[Store.ANIMAL].toString();
			clip.animalName.text = animalNames[animalChoice];
			clip.animalRes.gotoAndStop(animalChoice);
			
			var animalsVisible : Boolean = (store.pasturesAvailable(animalChoice));
			clip.animalAvailable.visible = animalsVisible;
			clip.animalBuyPrice.visible = animalsVisible;
			clip.animalName.visible = animalsVisible;
			clip.animalRes.visible = animalsVisible;
			clip.buyAnimalButton.visible = animalsVisible;
		}
		
		public function setPrices() : void
		{
			buyPrices = [0];
			sellPrices = [0];
			available = [0];
			
			animalChoice = Math.floor(Math.random() * 3) + 1;
			buyPrices[Store.ANIMAL] = 35 + animalChoice * 15;
			available[Store.ANIMAL] = 1;
			
			buyPrices[Store.GRAIN] = 12;
			sellPrices[Store.GRAIN] = 10;
			available[Store.GRAIN] = 11 + (Math.floor(Math.random() * 10));
			
			buyPrices[Store.FLOUR] = 16;
			sellPrices[Store.FLOUR] = 14;
			available[Store.FLOUR] = 4 + (Math.floor(Math.random() * 7));
			
			buyPrices[Store.BREAD] = 22;
			sellPrices[Store.BREAD] = 17;
			available[Store.BREAD] = 8 + (Math.floor(Math.random() * 8));
			
			buyPrices[Store.VEG] = 28;
			sellPrices[Store.VEG] = 22;
			available[Store.VEG] = 3 + (Math.floor(Math.random() * 7));
			
			buyPrices[Store.MEAT] = 35;
			sellPrices[Store.MEAT] = 28;
			available[Store.MEAT] = 3 + (Math.floor(Math.random() * 6));
			
			buyPrices[Store.WOOD] = 50;
			sellPrices[Store.WOOD] = 6;
			available[Store.WOOD] = 10 + (Math.floor(Math.random() * 10));
			
			if (Research.ref.enlightenment > 2)
			{
				for (var i : int = 0; i < available.length - 1; i++)
				{
					available[i] *= 2;
					if (Math.random() < 0.5)
					{
						available[i] += 1;
					}
				}
			} //end double quantity for sale
			
			if (Research.ref.enlightenment > 4)
			{
				buyPrices[Store.GRAIN] = 11;
				sellPrices[Store.GRAIN] = 10;
				
				buyPrices[Store.FLOUR] = 15;
				sellPrices[Store.FLOUR] = 14;
				
				buyPrices[Store.BREAD] = 20;
				sellPrices[Store.BREAD] = 18;
				
				buyPrices[Store.VEG] = 25;
				sellPrices[Store.VEG] = 23;
				
				buyPrices[Store.MEAT] = 32;
				sellPrices[Store.MEAT] = 30;
				
				buyPrices[Store.WOOD] = 40;
				sellPrices[Store.WOOD] = 8;
			}
		} //end setPrices
		
		private function buyAnimal(e:MouseEvent):void 
		{
			if (store.resource[Store.GOLD] >= buyPrices[Store.ANIMAL] && available[Store.ANIMAL] > 0)
			{
				var destination : Pasture = store.getFreePasture(animalChoice);
				destination.addAnimal(animalChoice);
				available[Store.ANIMAL]--;
				store.adjustStores(Store.GOLD, -buyPrices[Store.ANIMAL], new Point(624, 320));
				displayData();
			}
		}
		
		
	} //end class

}