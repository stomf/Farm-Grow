package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class Field extends EventDispatcher
	{
		public static const FIELD_WIDTH : int = 48;
		
		public static const WILD : int = 1;
		public static const PLOUGHED : int = 2;
		public static const HOUSE : int = 22;
		public static const GRAIN_SOWN : int = 4;
		public static const GRAIN_GROWN : int = 7;
		public static const SIGN : int = 23;
		public static const GRAVEYARD : int = 9;
		public static const SAPLINGS : int = 10;
		public static const SMALL_TREES : int = 12;
		public static const BIG_TREES : int = 13;
		public static const BIGGEST_TREES : int = 14;
		public static const VEG_PLANTED : int = 15;
		public static const VEG_GROWN : int = 18;
		public static const PASTURE : int = 19;
		public static const WELL : int = 20;
		public static const MILL : int = 21;
		
		public static const SCHOOL_COST : int = 25;
		
		private var clipArray : Array;
		private var parent : DisplayObjectContainer;
		public var baseClip : MovieClip;
		private var actionButton : SimpleButton;
		private var workIndicator : Sprite;
		public var fieldStatus : int;
		public var queuedAction : String;
		public var graveArray : Array;
		public var meeplesInTheGrave : Array;
		private var graveClip : MovieClip;
		public var growCount : int;
		private var store : Store;
		private var marketRef : MarketMenu;
	
		public function Field(newParent : DisplayObjectContainer, xLoc : int, storeRef: Store) : void
		{
			store = storeRef;
			parent = newParent;
			baseClip = new MovieClip;
			baseClip.x = xLoc;
			baseClip.y = 340;
			clipArray = [];
			fieldStatus = WILD;
			queuedAction = "";
			graveArray = [];
			meeplesInTheGrave = [];
			
			for (var i : int = 0; i < 3; i++)
			{
				var newGroundTile : MovieClip = new LandBlock();
				newGroundTile.gotoAndStop(1);
				newGroundTile.x = i * 16;
				baseClip.addChild(newGroundTile);
				clipArray.push(newGroundTile);
				newGroundTile.mouseEnabled = false;
				newGroundTile.mouseChildren = false;
				baseClip.mouseEnabled = false;
			}
			
			actionButton = new DiamondButton();
			baseClip.addChild(actionButton);
			workIndicator = new WorkIndicator();
			baseClip.addChild(workIndicator);
			workIndicator.mouseEnabled = false;
			workIndicator.visible = false;
			actionButton.addEventListener(MouseEvent.CLICK, buttonPressed);
			parent.addChild(baseClip);
		}
		
		public function dispose() : void
		{
			if (marketRef != null)
			{
				marketRef.dispose();
				marketRef = null;
			}
			for each (var m : MovieClip in clipArray)
			{
				baseClip.removeChild(m);
			}
			clipArray = [];
			for each (var g : MovieClip in graveArray)
			{
				g.removeEventListener(MouseEvent.ROLL_OVER, mouseEnteredGrave);
				g.removeEventListener(MouseEvent.ROLL_OUT, mouseLeftGrave);
				baseClip.removeChild(g);
			}
			graveArray = [];
			for each (var f : FamilyMeeple in meeplesInTheGrave)
			{
				f.dispose();
			}
			meeplesInTheGrave = [];
			store = null;
			clipArray = [];
			baseClip.removeChild(actionButton);
			baseClip.removeChild(workIndicator);
			actionButton.removeEventListener(MouseEvent.CLICK, buttonPressed);
			parent.removeChild(baseClip);
			parent = null;
		}
		
		private function buttonPressed(e:MouseEvent):void 
		{
			dispatchEvent(new GameEvent(GameEvent.ACTION_BUTTON_PRESSED));
		}
		
		public function addHouse() : void
		{
			var houseClip : MovieClip = new HouseClip();
			baseClip.addChild(houseClip);
			clipArray.push(houseClip);
			fieldStatus = HOUSE;
			houseClip.addEventListener(MouseEvent.ROLL_OVER, mouseOverHouse);
			houseClip.addEventListener(MouseEvent.ROLL_OUT, mouseLeftHouse);
		}
		
		public function addSign() : void
		{
			var signClip : MovieClip = new SignClip();
			baseClip.addChild(signClip);
			clipArray.push(signClip);
			fieldStatus = SIGN;
		}
		
		private function mouseLeftHouse(e:MouseEvent):void 
		{
			store.hideInventory();
		}
		
		private function mouseOverHouse(e:MouseEvent):void 
		{
		
			store.showInventory();
		}
		
		public function bury(meeple : FamilyMeeple) : void
		{
			if (graveArray.length == 0 || fieldStatus != GRAVEYARD)
			{
				buildGraveyard();
			}
			
			var newGrave : MovieClip = new GraveClip();
			baseClip.addChild(newGrave);
			graveArray.push(newGrave);
			meeplesInTheGrave.push(meeple);
			newGrave.x = graveArray.length * 16;
			newGrave.addEventListener(MouseEvent.ROLL_OVER, mouseEnteredGrave);
			newGrave.addEventListener(MouseEvent.ROLL_OUT, mouseLeftGrave);
		}
		
		private function mouseLeftGrave(e:MouseEvent):void 
		{
			graveClip.parent.removeChild(graveClip);
			graveClip = null;
		}
		
		private function mouseEnteredGrave(e:MouseEvent):void 
		{
			var i : int  = Math.round(e.currentTarget.x / 16) - 1;
			graveClip = new GraveMarkerClip();
			graveClip.mouseChildren = false;
			parent.addChild(graveClip);
			var deadMeeple : FamilyMeeple = meeplesInTheGrave[i];
			graveClip.meepleName.text = deadMeeple.name;
			var familyTree : String = "";
			if (deadMeeple.parentName == "Founder")
			{
				familyTree = "Founder of the family. ";
			}
			else if (deadMeeple.parentName == "distant relative.")
			{
				familyTree = "Child of a distant relative. ";
			}
			else if (deadMeeple.parentName != "")
			{
				familyTree = "Child of " + deadMeeple.parentName + ". ";
			}
			if (deadMeeple.spouseName != "")
			{
				familyTree += "Beloved of " + deadMeeple.spouseName + ".";
			}
			graveClip.familyTree.text = familyTree;
			graveClip.dateNote.text = "Born " + deadMeeple.bornDate + "AD, died " + deadMeeple.diedDate + "AD";
			graveClip.stats.text = deadMeeple.returnBestAccomplishments();
		}
		
		private function buildGraveyard():void
		{
			cancelAction();
			queuedAction = "";
			demolish();
			fieldStatus = GRAVEYARD;
			setClipAppearance(9);
		}
		
		public function getActionList() : Array
		{
			var answer : Array = [];
			if (queuedAction != "")
			{
				var firstWord : String = queuedAction.split(" ")[0];
				answer.push ("Cancel " + firstWord);
			}
			
			if (fieldStatus == GRAIN_GROWN && queuedAction != FamilyMeeple.HARVEST)
			{
				answer.push (FamilyMeeple.HARVEST);
			}
			if (fieldStatus == VEG_GROWN && queuedAction != FamilyMeeple.HARVEST)
			{
				answer.push (FamilyMeeple.HARVEST);
			}
			if (fieldStatus == PLOUGHED && queuedAction != FamilyMeeple.SOW_GRAIN && store.resource[Store.GRAIN] > 0 && Research.ref.productivity > 2)
			{
				answer.push (FamilyMeeple.SOW_GRAIN);
			}
			if (fieldStatus == PLOUGHED && queuedAction != FamilyMeeple.PLANT_VEG && store.resource[Store.VEG] > 0)
			{
				answer.push (FamilyMeeple.PLANT_VEG);
			}
			if ((fieldStatus == GRAIN_SOWN || fieldStatus == WILD || fieldStatus == SAPLINGS || fieldStatus == VEG_PLANTED) && queuedAction != FamilyMeeple.PLOUGH_FIELD)
			{
				answer.push (FamilyMeeple.PLOUGH_FIELD);
			}
			if (fieldStatus == SMALL_TREES && queuedAction.substr(0, 10) != "Chop Trees")
			{
				answer.push (FamilyMeeple.CHOP_TREES_1);
			}
			if (fieldStatus == BIG_TREES && queuedAction.substr(0, 10) != "Chop Trees")
			{
				answer.push (FamilyMeeple.CHOP_TREES_3);
			}	
			if (fieldStatus == BIGGEST_TREES && queuedAction.substr(0, 10) != "Chop Trees")
			{
				answer.push (FamilyMeeple.CHOP_TREES_5);
			}
			if ((fieldStatus == PLOUGHED|| fieldStatus == WILD) && queuedAction != FamilyMeeple.PLANT_TREES)
			{
				answer.push (FamilyMeeple.PLANT_TREES);
			}
			if ((fieldStatus == PLOUGHED || fieldStatus == WILD) && queuedAction != FamilyMeeple.BUILD_FENCES && store.resource[Store.WOOD] > 19 && Research.ref.infrastructure > 2)
			{
				answer.push(FamilyMeeple.BUILD_FENCES);
			}
			if ((fieldStatus == PLOUGHED || fieldStatus == WILD) && queuedAction != FamilyMeeple.BUILD_MILL && store.resource[Store.WOOD] > 29 && Research.ref.infrastructure > 3)
			{
				answer.push(FamilyMeeple.BUILD_MILL);
			}
			if ((fieldStatus == PLOUGHED || fieldStatus == WILD) && queuedAction != FamilyMeeple.BUILD_WELL && store.resource[Store.WOOD] > 49 && Research.ref.infrastructure > 5)
			{
				answer.push(FamilyMeeple.BUILD_WELL);
			}
			if (fieldStatus == HOUSE && queuedAction != FamilyMeeple.GROW_FAMILY && store.resource[Store.FAMILY_SIZE] < 12)
			{
				answer.push(FamilyMeeple.GROW_FAMILY);
			}
			if (fieldStatus == HOUSE && queuedAction != FamilyMeeple.RESEARCH)
			{
				answer.push(FamilyMeeple.RESEARCH);
			}
			if (fieldStatus == HOUSE && queuedAction != FamilyMeeple.BAKE_BREAD && Research.ref.infrastructure > 4 && store.resource[Store.FLOUR] > 1)
			{
				answer.push(FamilyMeeple.BAKE_BREAD);
			}
			if (fieldStatus == SIGN && queuedAction != FamilyMeeple.GO_TO_MARKET)
			{
				answer.push(FamilyMeeple.GO_TO_MARKET);
			}
			if (fieldStatus == SIGN && queuedAction != FamilyMeeple.GO_TO_SCHOOL && store.resource[Store.GOLD] >= SCHOOL_COST)
			{
				answer.push(FamilyMeeple.GO_TO_SCHOOL);
			}
			if (fieldStatus == SIGN && queuedAction != FamilyMeeple.GO_TO_WORK)
			{
				answer.push(FamilyMeeple.GO_TO_WORK);
			}
			if (fieldStatus == GRAVEYARD && queuedAction != FamilyMeeple.MOURN_THE_DEAD)
			{
				answer.push(FamilyMeeple.MOURN_THE_DEAD);
			}
			if ((fieldStatus == MILL || fieldStatus == WELL || fieldStatus == PASTURE) && queuedAction != FamilyMeeple.DEMOLISH)
			{
				answer.push(FamilyMeeple.DEMOLISH);
			}
			if (fieldStatus == WELL && queuedAction != FamilyMeeple.DRAW_WATER)
			{
				answer.push(FamilyMeeple.DRAW_WATER);
			}
			if (fieldStatus == MILL && queuedAction != FamilyMeeple.MILL_FLOUR && store.resource[Store.GRAIN] > 1)
			{
				answer.push(FamilyMeeple.MILL_FLOUR);
			}
			if (fieldStatus == PASTURE)
			{
				var p : Pasture = getPasture();
				if (p.animalType == Pasture.COW)
				{
					if (queuedAction != FamilyMeeple.COOK_COW)
					{
						answer.push(FamilyMeeple.COOK_COW);
					}
				}
				if (p.animalType == Pasture.PIG)
				{
					if (queuedAction != FamilyMeeple.COOK_PIG)
					{
						answer.push(FamilyMeeple.COOK_PIG);
					}
				}
				if (p.animalType == Pasture.SHEEP)
				{
					if (queuedAction != FamilyMeeple.COOK_SHEEP)
					{
						answer.push(FamilyMeeple.COOK_SHEEP);
					}
				}
			}
			return answer;
		}
		
		public function getPasture() : Pasture
		{
			return store.getPasture(this);
		}
		
		public function getFieldX() : int
		{
			//returns x location of field centre;
			var answer : int = baseClip.x + 24;
			return answer;
		}
		
		public function fieldNumber() : int
		{
			//returns the field number (ie, location in the holdings array)
			return Math.floor(baseClip.x / FIELD_WIDTH);
		}
		
		public function addAction(newAction : String) : void
		{
			if (newAction.substr(0, 6) == "Cancel")
			{
				cancelAction();
				queuedAction = "";
			}
			else 
			{
				if (queuedAction != "")
				{
					cancelAction();
					//cancel previous job before issuing new one
				}
				queuedAction = newAction;
				workIndicator.visible = true;
				if (queuedAction == FamilyMeeple.SOW_GRAIN)
				{
					store.adjustStores(Store.GRAIN, -1, locPoint());
				}
				if (queuedAction == FamilyMeeple.GO_TO_SCHOOL)
				{
					store.adjustStores(Store.GOLD, -SCHOOL_COST, locPoint());
				}
				if (queuedAction == FamilyMeeple.PLANT_VEG)
				{
					store.adjustStores(Store.VEG, -1, locPoint());
				}
				if (queuedAction == FamilyMeeple.BUILD_FENCES)
				{
					store.adjustStores(Store.WOOD, -20, locPoint());
				}
				if (queuedAction == FamilyMeeple.BUILD_WELL)
				{
					store.adjustStores(Store.WOOD, -50, locPoint());
				}
				if (queuedAction == FamilyMeeple.BUILD_MILL)
				{
					store.adjustStores(Store.WOOD, -30, locPoint());
				}
				if (queuedAction == FamilyMeeple.BAKE_BREAD)
				{
					store.adjustStores(Store.FLOUR, -2, locPoint());
				}
				if (queuedAction == FamilyMeeple.MILL_FLOUR)
				{
					store.adjustStores(Store.GRAIN, -2, locPoint());
				}
			}
		}
		
		private function cancelAction() : void
		{
			workIndicator.visible = false;
			if (queuedAction == FamilyMeeple.SOW_GRAIN)
			{
				store.adjustStores(Store.GRAIN, 1, locPoint());
			}
			if (queuedAction == FamilyMeeple.GO_TO_SCHOOL)
			{
				store.adjustStores(Store.GOLD, SCHOOL_COST, locPoint());
			}
			if (queuedAction == FamilyMeeple.PLANT_VEG)
			{
				store.adjustStores(Store.VEG, 1, locPoint());
			}
			if (queuedAction == FamilyMeeple.BUILD_FENCES)
			{
				store.adjustStores(Store.WOOD, 20, locPoint());
			}
			if (queuedAction == FamilyMeeple.BUILD_WELL)
			{
				store.adjustStores(Store.WOOD, 50, locPoint());
			}
			if (queuedAction == FamilyMeeple.BUILD_MILL)
			{
				store.adjustStores(Store.WOOD, 30, locPoint());
			}
			if (queuedAction == FamilyMeeple.BAKE_BREAD)
			{
				store.adjustStores(Store.FLOUR, 2, locPoint());
			}
			if (queuedAction == FamilyMeeple.MILL_FLOUR)
			{
				store.adjustStores(Store.GRAIN, 2, locPoint());
			}
			dispatchEvent(new GameEvent(GameEvent.ACTION_CANCELLED));
		}
		
		public function jobComplete() : void
		{
			if (queuedAction.substr(0, 10) == "Chop Trees")
			{
				chopTrees();
			}
			if (queuedAction == FamilyMeeple.BAKE_BREAD)
			{
				store.adjustStores(Store.BREAD, +3, locPoint());
			}
			if (queuedAction == FamilyMeeple.PLANT_TREES)
			{
				plantTreesComplete();
			}
			if (queuedAction == FamilyMeeple.PLANT_VEG)
			{
				plantVegComplete();
			}
			if (queuedAction == FamilyMeeple.PLOUGH_FIELD)
			{
				ploughFieldComplete();
			}
			if (queuedAction == FamilyMeeple.SOW_GRAIN)
			{
				sowGrainComplete();
			}
			if (queuedAction == FamilyMeeple.HARVEST)
			{
				harvestComplete();
			}
			if (queuedAction == FamilyMeeple.GO_TO_MARKET)
			{
				marketRef = new MarketMenu(parent, store);
			}
			if (queuedAction == FamilyMeeple.GO_TO_SCHOOL)
			{
				educate();
			}
			if (queuedAction == FamilyMeeple.GO_TO_WORK)
			{
				dayLabour();
			}
			if (queuedAction == FamilyMeeple.MOURN_THE_DEAD)
			{
				store.adjustStores(Store.HEALTH, 1, locPoint());
			}
			if (queuedAction == FamilyMeeple.DRAW_WATER)
			{
				store.adjustStores(Store.HEALTH, 2, locPoint());
			}
			if (queuedAction == FamilyMeeple.RESEARCH)
			{
				Research.showResearch();
			}
			if (queuedAction == FamilyMeeple.BUILD_FENCES)
			{
				pastureBuilt();
			}
			if (queuedAction == FamilyMeeple.BUILD_MILL)
			{
				buildMill();
			}
			if (queuedAction == FamilyMeeple.BUILD_WELL)
			{
				buildWell();
				store.wellsOwned++;
			}
			if (queuedAction == FamilyMeeple.DEMOLISH)
			{
				demolish();
			}
			if (queuedAction == FamilyMeeple.MILL_FLOUR)
			{
				store.adjustStores(Store.FLOUR, +2, locPoint());
			}
			if (queuedAction == FamilyMeeple.COOK_COW)
			{
				cookCow();
			}
			if (queuedAction == FamilyMeeple.COOK_PIG)
			{
				cookPig();
			}
			if (queuedAction == FamilyMeeple.COOK_SHEEP)
			{
				cookSheep();
			}
			queuedAction = "";
			workIndicator.visible = false;
		}
		
		private function cookCow():void
		{
			var p : Pasture = getPasture();
			p.removeAnimal();
			store.adjustStores(Store.MEAT, 5, locPoint());
		}
		
		private function cookPig():void
		{
			var p : Pasture = getPasture();
			p.removeAnimal();
			store.adjustStores(Store.MEAT, 3, locPoint());
		}
		
		private function cookSheep():void
		{
			var p : Pasture = getPasture();
			p.removeAnimal();
			store.adjustStores(Store.MEAT, 4, locPoint());
		}
		
		private function demolish():void
		{
			if (fieldStatus == WELL)
			{
				store.wellsOwned--;
			}
			if (fieldStatus == PASTURE)
			{
				store.pastureDestroyed(this);
			}
			fieldStatus = WILD;
			setClipAppearance(1);
		}
		
		private function buildWell():void
		{
			fieldStatus = WELL;
			setClipAppearance(9);
			clipArray[1].gotoAndStop(20);
		}
		
		private function buildMill():void
		{
			fieldStatus = MILL;
			setClipAppearance(9);
			clipArray[1].gotoAndStop(21);
		}
		
		private function pastureBuilt():void
		{
			setClipAppearance(9);
			fieldStatus = PASTURE;
			growCount = 0;
			store.addPasture(this);
		}
		
		private function chopTrees():void
		{
			store.adjustStores(Store.WOOD, getYield(), locPoint());
			fieldStatus = WILD;
			setClipAppearance(1);
			growCount = 0;
		}
		
		private function plantTreesComplete():void
		{
			fieldStatus = SAPLINGS;
			setClipAppearance(10);
			growCount = 0;
		}
		
		private function dayLabour():void
		{
			var income : int = 5;
			if (Research.ref.enlightenment > 1)
			{
				income = 8;
			}
			if (Research.ref.enlightenment > 5)
			{
				income = 15;
			}
			store.adjustStores(Store.GOLD, income, locPoint());
		}
		
		private function educate():void
		{
			var learning : int = 10;
			if (Research.ref.enlightenment > 6)
			{
				learning *= 2;
			}
			store.adjustStores(Store.KNOWLEDGE, learning, locPoint());
		}
		
		private function setClipAppearance (frameNo : int) : void
		{
			for (var i : int = 0; i < 3; i++)
			{
				clipArray[i].gotoAndStop(frameNo);
			}
		}
		
		public function newLoad() : void
		{
			setClipAppearance(fieldStatus);
			if (queuedAction != "")
			{
				workIndicator.visible = true;
				//trace (queuedAction);
			}
			if (fieldStatus == MILL)
			{
				buildMill();
			}
			if (fieldStatus == WELL)
			{
				buildWell();
				store.wellsOwned++;
			}
			
		}
		
		private function locPoint() : Point
		{
			return new Point(baseClip.x + 20, baseClip.y-20);
		}
		
		private function harvestComplete():void
		{
			if (fieldStatus == GRAIN_GROWN)
			{
				store.adjustStores(Store.GRAIN, getYield(), locPoint());
			}
			if (fieldStatus == VEG_GROWN)
			{
				store.adjustStores(Store.VEG, getYield(), locPoint());
			}
			fieldStatus = WILD;
			setClipAppearance(9);
			growCount = 0;
			
		}
		
		private function plantVegComplete():void
		{
			fieldStatus = VEG_PLANTED;
			setClipAppearance(15);
			growCount = 0;
		}
		
		private function sowGrainComplete():void
		{
			fieldStatus = GRAIN_SOWN;
			setClipAppearance(4);
			growCount = 0;
		}
		
		private function ploughFieldComplete():void
		{
			fieldStatus = PLOUGHED;
			setClipAppearance(2);
		}
		
		private function getYield() : int
		{
			var answer : int = 0;
			switch (fieldStatus)
			{
				case (GRAIN_GROWN):
					answer = 3;
				break;
				case (VEG_GROWN):
					answer = 2;
				break;
				case (SMALL_TREES):
					answer = 1;
				break;
				case (BIG_TREES):
					answer = 3;
				break;
				case (BIGGEST_TREES):
					answer = 5;
				break;
				
			}
			if (fieldStatus == GRAIN_GROWN || fieldStatus == VEG_GROWN)
			{
				if (Research.ref.productivity > 3)
				{
					answer++;
				}
				if (Research.ref.productivity > 5)
				{
					answer++;
				}
			}
			if (Research.ref.productivity > 6 && fieldStatus >= SMALL_TREES && fieldStatus <= BIGGEST_TREES)
			{
				answer *= 2;
			}
			return answer;
		}
		
		private function growTime() : int
		{
			var answer : int = 5000000;
			if (fieldStatus == GRAIN_SOWN)
			{
				answer = 9;
			}
			if (fieldStatus == VEG_PLANTED)
			{
				answer = 12;
			}
			if (Research.ref.productivity > 4)
			{
				answer = Math.round(answer * 0.6666);
			}
			if (fieldStatus == SAPLINGS)
			{
				answer = 14;
			}
			if (fieldStatus == SMALL_TREES)
			{
				answer = 20;
			}
			if (fieldStatus == BIG_TREES)
			{
				answer = 30;
			}
			return answer;
		}
		
		public function tick() : void
		{
			growCount++;
			if (growCount >= growTime()) //every 5 ticks (2 times a day)
			{
				var nextFrame : int = clipArray[0].currentFrame + 1;
				growCount = 0;
				if (fieldStatus == VEG_PLANTED)
				{
					setClipAppearance(nextFrame);
					if (nextFrame == 18)
					{
						fieldStatus = VEG_GROWN;
					}
				}
				if (fieldStatus == GRAIN_SOWN)
				{
					setClipAppearance(nextFrame);
					if (nextFrame == 7)
					{
						fieldStatus = GRAIN_GROWN;
					}
				}
				else if (fieldStatus == SAPLINGS)
				{
					setClipAppearance(nextFrame);
					if (nextFrame == 12)
					fieldStatus = SMALL_TREES;
				}
				else if (fieldStatus == SMALL_TREES)
				{
					setClipAppearance(nextFrame);
					fieldStatus = BIG_TREES;
				}
				else if (fieldStatus == BIG_TREES)
				{
					setClipAppearance(nextFrame);
					fieldStatus = BIGGEST_TREES;
				}
				
				
			} 
		} //end tick function
		
	} //end class

}