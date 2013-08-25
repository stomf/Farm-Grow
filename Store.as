package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class Store
	{
		public static const ANIMAL : int = 0;
		public static const GOLD : int = 1;
		public static const GRAIN : int = 2;
		public static const WOOD : int = 3;
		public static const FLOUR : int = 4;
		public static const KNOWLEDGE : int = 5;
		public static const MEAT : int = 6;
		public static const BREAD : int = 7;
		public static const VEG : int = 8;
		public static const FAMILY_SIZE : int = 9;
		public static const HEALTH : int = 10;
		
		public var resource : Array;
		public var wellsOwned : int;
		public var pastures : Array;
		private var inventoryClip : MovieClip;
		
		private static const tips : Array = [
			"You need to buy grain from the market before you can sow it.",
			"You need to research productibity 2 before you can sow grain.",
			"You need to build a well to gain the benefits of researching it.",
			"Wood is used for constructing buildings.",
			"If you eat all your vegetables you can't plant any more.",
			"Each family member eats one food twice a day.",
			"Vegetables take longer to grow than grain.",
			"Trees yield more wood if you let them grow fully.",
			"You need 25 gold before you can send someone to school",
			"You can gain knowledge by sending family to school.",
			"Special actions are available in the sign and the house.",
			"Graveyards are built to the left of the house.",
			"When a new graveyard is needed it destroys whatever is in the way.",
			"The game ends when 12 of your family have died.",
			"Eating a variety of different foods improves health.",
			"Health will help your family live longer.",
			"The maximum health can be increased by some research.",
			"Only one person can visit town at a time.",
			"When looking for a task, unemployed family will go to the closest one.",
			"You can cancel a task if it hasn't been finished.",
			"You need 20 wood before you can build a pasture.",
			"A well requires 50 wood to build.",
			"There are 18 skills to research.",
			"You can buy animals from the market if you have an empty pasture.",
			"A pasture can hold four animals, if they are the same type.",
			"You need two animals of the same type before they will breed.",
			"Grain can be milled into flour, then baked into bread.",
			"Having a well built increases the maximum health.",
			"Health increases the life expectancy of your family.",
			"Living alone is not healthy.",
			"Eating just one type of food will lower health.",
			"The game ends when 12 of your family have died."]
		
		public function Store(parent : DisplayObjectContainer) : void
		{
			pastures = [];
			resource = [0];
			resource[GOLD] = 50;
			resource[GRAIN] = 0;
			resource[WOOD] = 0;
			resource[FLOUR] = 0;
			resource[KNOWLEDGE] = 0;
			resource[MEAT] = 000;
			resource[BREAD] = 11;
			resource[VEG] = 10;
			resource[FAMILY_SIZE] = 0;
			resource[HEALTH] = 40;
			wellsOwned = 0;
			inventoryClip = new InventoryClip();
			parent.addChild(inventoryClip);
			inventoryClip.visible = false;
			updateInventory();
		}
		
		public function dispose() : void
		{
			for each (var p : Pasture in pastures)
			{
				p.dispose();
			}
			pastures = [];
			resource = [];
			inventoryClip.parent.removeChild(inventoryClip);
			inventoryClip = null;
		}
		
		public function totalFood() : int
		{
			return resource[BREAD] + resource[VEG] + resource[MEAT];
		}
		
		public function showInventory() : void
		{
			inventoryClip.visible = true;
			inventoryClip.tips.text = "Tip: "  + tips[Math.floor(Math.random() * tips.length)];
		}
		
		public function hideInventory() : void
		{
			inventoryClip.visible = false;
		}
		
		public function updateInventory() : void
		{
			inventoryClip.gold.text = resource[GOLD].toString();
			inventoryClip.grain.text = resource[GRAIN].toString();
			inventoryClip.wood.text = resource[WOOD].toString();
			inventoryClip.flour.text = resource[FLOUR].toString();
			inventoryClip.knowledge.text = resource[KNOWLEDGE].toString();
			inventoryClip.meat.text = resource[MEAT].toString();
			inventoryClip.bread.text = resource[BREAD].toString();
			inventoryClip.veg.text = resource[VEG].toString();
			inventoryClip.family.text = resource[FAMILY_SIZE].toString();
			inventoryClip.health.text = resource[HEALTH].toString();
		}
		
		public function totalWealth () : int
		{
			var total : int = resource[GOLD];
			total += resource[GRAIN] * 10;
			total += resource[WOOD] * 8;
			total += resource[FLOUR] * 14;
			total += resource[BREAD] * 18;
			total += resource[VEG] * 23;
			total += resource[MEAT] * 30;
			return total;
		}
		
		public function adjustStores(commodity : int, amount : int, location : Point) : void
		{
			//health has min and max values
			var maxHealth : int = 60;
			if (Research.ref.enlightenment > 3)
			{
				maxHealth += 20;
			}
			if (wellsOwned > 0)
			{
				maxHealth += 20;
			}
			if (commodity == HEALTH)
			{
				if (amount + resource[HEALTH] > maxHealth)
				{
					amount = maxHealth - resource[HEALTH];
				}
				if (amount + resource[HEALTH] < 1)
				{
					amount = 1 - resource[HEALTH];
				}
			}
			resource[commodity] += amount;
			updateInventory();
			var newFloatingText : AdjustAdvice = new AdjustAdvice(inventoryClip.parent, commodity, location, amount);
		}
		
		public function addPasture(field : Field) : void
		{
			var newPasture : Pasture = new Pasture(field);
			pastures.push(newPasture);
		}
		
		public function pastureDestroyed(field : Field) : void
		{
			for each (var p : Pasture in pastures)
			{
				if (p.field == field)
				{
					p.dispose();
				}
			}
			for (var i : int = pastures.length-1; i >= 0; i--)
			{
				if (pastures[i].destroyed)
				{
					pastures.splice(i, 1);
				}
			}
		}
		
		public function pasturesAvailable(animalForSale : int) : Boolean
		{
			var answer : Boolean = false;
			for each (var p : Pasture in pastures)
			{
				if (p.animalType == Pasture.EMPTY)
				{
					answer = true;
				}
				if (p.animalType == animalForSale && p.animals < 4)
				{
					answer = true;
				}
			}
			return answer;
		}
		
		public function getFreePasture(animalForSale : int) : Pasture
		{
			var answer : Pasture = null;
			var p : Pasture;
			for each (p in pastures)
			{
				if (p.animalType == Pasture.EMPTY)
				{
					answer = p;
				}
			}
			for each (p in pastures)
			{
				if (p.animalType == animalForSale && p.animals < 4)
				{
					answer = p;
				}
			}
			return answer;
		}
		
		public function checkPastures() : void
		{
			for each (var p : Pasture in pastures)
			{
				p.tickField();
			}
		}
		
		public function getPasture(field : Field)
		{
			var answer : Pasture = null;
			for each (var p : Pasture in pastures)
			{
				if (p.field == field)
				{
					answer = p;
				}
			}
			return answer;
		}
		
	}

}