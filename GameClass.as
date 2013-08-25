package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class GameClass extends EventDispatcher
	{
		private var holdings : Array;
		private var stageRef : DisplayObjectContainer;
		private var skyClip : Sprite;
		private var actionMenu : ActionMenu;
		private var family : Array;
		private var tickCount : int;
		private var store : Store;
		private var speedButtonx0 : MovieClip;
		private var speedButtonx1 : MovieClip;
		private var speedButtonx2 : MovieClip;
		private var speedButtonx4 : MovieClip;
		private var quitButton : SimpleButton;
		private var gameSpeed : int;
		private var houseXLoc : int;
		private var currentYear : int;
		private var kongregate : * ;
		private var gameOver : Boolean;
		private var gameEndClip : MovieClip;
		private var saveGameRef : SharedObject;
		private var gameMode : int;
		private var mountain : Sprite;
		private var pi : PlayerInput;
		
		public static const NORMAL : int = 0;
		public static const SANDBOX : int = 1;
		public static const HARDCORE : int = 2;
		
		public function GameClass(newParent : DisplayObjectContainer, kongRef : *, newGame : Boolean, sGame : SharedObject, mode : int) : void
		{
			gameMode = mode;
			kongregate = kongRef;
			saveGameRef = sGame;
			currentYear = 1000;
			stageRef = newParent;
			pi = new PlayerInput(stageRef);
			actionMenu = new ActionMenu(stageRef);
			buildSky();
			store = new Store(stageRef);
			var researchBoard : Research = new Research(stageRef, store);
			mountain = new Mountain();
			stageRef.addChild(mountain);
			buildFarm();
			
			stageRef.stage.addEventListener(Event.ENTER_FRAME, eachFrame);
			tickCount = 0;
			addSpeedButtons();
			if (newGame)
			{
				startFamily();
				var goodLuck : MessageBox = new MessageBox(stageRef, family[0].name + " has come to this land to build a farm and start a family. Their fate is in your hands.");
			}
		}
		
		private function returnToMenu(e:MouseEvent = null):void 
		{
			stageRef.stage.removeEventListener(Event.ENTER_FRAME, eachFrame);
			dispatchEvent(new GameEvent(GameEvent.GAME_SUSPENDED));
		}
		
		public static function reload(saveGame : SharedObject, parent : DisplayObjectContainer, kongRef: *) : GameClass
		{
			var mode : int = 0;
			try
			{
				mode = saveGame.data.gameMode;
			}
			catch (e : Error)
			{
				mode = 0;
				//trace (e.message);
			}
			var newGame : GameClass = new GameClass(parent, kongRef, false, saveGame, mode);
			newGame.insertData(saveGame);
			return newGame;
		}
		
		public function insertData(saveGame : SharedObject) : void
		{
			currentYear = saveGame.data.currentYear;
			tickCount = saveGame.data.tickCount;
			gameOver = saveGame.data.gameOver;
			skyClip.x = saveGame.data.skyloc;
			family = [];
			
			var f_status : Array = saveGame.data.f_status;
			var f_queuedAction : Array = saveGame.data.f_queuedAction;
			var f_growProgress : Array = saveGame.data.f_growProgress;
			
			for (var i : int = 0; i < f_status.length; i++)
			{
				holdings[i].fieldStatus = f_status[i];
				holdings[i].queuedAction = f_queuedAction[i];
				holdings[i].growCount = f_growProgress[i];
				holdings[i].newLoad();
				if (holdings[i].fieldStatus == Field.PASTURE)
				{
					store.addPasture(holdings[i]);
					holdings[i].getPasture().animals = saveGame.data.f_animals[i];
					holdings[i].getPasture().animalType = saveGame.data.f_animalType[i];
					holdings[i].getPasture().timer = saveGame.data.f_animalTimer[i];
					holdings[i].getPasture().display();
				}
			}
			
			var m_name : Array = saveGame.data.m_name;
			var m_age : Array = saveGame.data.m_age;
			var m_bornDate : Array = saveGame.data.m_bornDate;
			var m_diedDate : Array = saveGame.data.m_diedDate;
			var m_spouseName : Array = saveGame.data.m_spouseName;
			var m_parentName : Array = saveGame.data.m_parentName;
			var m_married : Array = saveGame.data.m_married;
			var m_xLoc : Array = saveGame.data.m_xLoc;
			var m_targetLoc : Array = saveGame.data.m_targetLoc;
			var m_graveLoc : Array = saveGame.data.m_graveLoc;
			var m_jobProgress : Array = saveGame.data.m_jobProgress;
			var m_jobLength : Array = saveGame.data.m_jobLength;
			var m_accomplishments : Array = saveGame.data.m_accomplishments;
			var m_colour : Array = saveGame.data.m_colour;
			
			for (var j : int = 0; j < m_name.length; j++)
			{
				var m : FamilyMeeple = new FamilyMeeple(stageRef, m_xLoc[j], m_colour[j]);
				m.name = m_name[j];
				m.age = m_age[j];
				m.bornDate = m_bornDate[j];
				m.diedDate = m_diedDate[j];
				m.spouseName = m_spouseName[j];
				m.parentName = m_parentName[j];
				m.married = m_married[j];
				m.targetLocation = m_targetLoc[j];
				m.jobProgress = m_jobProgress[j];
				m.jobLength = m_jobLength[j];
				m.addEventListener(GameEvent.JOB_FINISHED, jobFinished);
				m.accomplishments = m_accomplishments[j];
				m.graveLocation = m_graveLoc[j];
				//to do graves, accomplishments
				if (m.diedDate != 0)
				{
					//trace (holdings.length);
					var burialField : int = m_graveLoc[j];
					//trace (burialField);
					var field : Field = holdings[burialField];
					//trace (field);
					field.bury(m);
					m.clip.visible = false;
				}
				else
				{
					family.push(m);	
					m.clip.visible = true;
				}
			}

			store.resource = saveGame.data.resources;
			store.updateInventory();
			Research.ref.enlightenment = saveGame.data.enl;
			Research.ref.infrastructure = saveGame.data.inf;
			Research.ref.productivity = saveGame.data.prd;
			if (gameOver)
			{
				endGame();
			}
			
		}
		
		public function save(saveGame : SharedObject) :void
		{
			saveGame.data.gameMode = gameMode;
			saveGame.data.exists = true;
			saveGame.data.currentYear = currentYear;
			saveGame.data.tickCount = tickCount;
			saveGame.data.gameOver = gameOver;
			saveGame.data.skyloc = Math.floor(skyClip.x);
			var f_status : Array = [];
			var f_queuedAction : Array = [];
			var f_growProgress : Array = [];
			var f_animals : Array = [];
			var f_animalType : Array = [];
			var f_animalTimer : Array = [];
			//trace ('save check 1');
			for each (var f : Field in holdings)
			{
				f_status.push(f.fieldStatus);
				f_queuedAction.push(f.queuedAction);
				f_growProgress.push(f.growCount);
				if (f.fieldStatus == Field.PASTURE)
				{
					f_animals.push(f.getPasture().animals);
					f_animalType.push(f.getPasture().animalType);
					f_animalTimer.push(f.getPasture().timer);
				}
				else
				{
					f_animals.push(0);
					f_animalType.push(0);
					f_animalTimer.push(0);
				}
			}
			//trace ('save check 2');
			saveGame.data.f_status = f_status;
			saveGame.data.f_queuedAction = f_queuedAction;
			saveGame.data.f_growProgress = f_growProgress;
			saveGame.data.f_animals = f_animals;
			saveGame.data.f_animalType = f_animalType;
			saveGame.data.f_animalTimer = f_animalTimer;
			
			var m_name : Array = [];
			var m_age : Array = [];
			var m_bornDate : Array = [];
			var m_diedDate : Array = [];
			var m_spouseName : Array = [];
			var m_parentName : Array = [];
			var m_married : Array = [];
			var m_xLoc : Array = [];
			var m_targetLoc : Array = [];
			var m_graveLoc : Array = [];
			var m_jobProgress : Array = [];
			var m_jobLength : Array = [];
			var m_accomplishments : Array = [];
			var m_colour : Array = [];
			var m : FamilyMeeple;
			//trace ('save check 3');
			for (var meep : int = 0; meep < family.length; meep++)
			{
				m = family[meep];
				m_name.push(m.name);
				m_colour.push(m.colour);
				m_age.push(m.age);
				m_bornDate.push(m.bornDate);
				m_diedDate.push(m.diedDate);
				m_spouseName.push(m.spouseName);
				m_parentName.push(m.parentName);
				m_married.push(m.married);
				m_xLoc.push(Math.floor(m.clip.x));
				m_targetLoc.push(m.targetLocation);
				m_graveLoc.push(m.graveLocation);
				m_jobProgress.push(Math.floor(m.jobProgress));
				m_jobLength.push(m.jobLength);
				m_accomplishments.push(m.accomplishments);
			}
			//trace ('save check 4');
			for each (var gravefield : Field in holdings)
			{
				for each (m in gravefield.meeplesInTheGrave)
				{
					m_name.push(m.name);
					m_colour.push(m.colour);
					m_age.push(m.age);
					m_bornDate.push(m.bornDate);
					m_diedDate.push(m.diedDate);
					m_spouseName.push(m.spouseName);
					m_parentName.push(m.parentName);
					m_married.push(m.married);
					m_xLoc.push(Math.floor(m.clip.x));
					m_targetLoc.push(m.targetLocation);
					m_graveLoc.push(m.graveLocation);
					m_jobProgress.push(Math.floor(m.jobProgress));
					m_jobLength.push(m.jobLength);
					m_accomplishments.push(m.accomplishments);
				}
			}
			//trace ('save check 5');
			saveGame.data.exists = true;
			saveGame.data.m_name = m_name;
			saveGame.data.m_colour = m_colour;
			saveGame.data.m_age = m_age;
			saveGame.data.m_bornDate = m_bornDate;
			saveGame.data.m_diedDate = m_diedDate;
			saveGame.data.m_spouseName = m_spouseName;
			saveGame.data.m_parentName = m_parentName;
			saveGame.data.m_married = m_married;
			saveGame.data.m_xLoc = m_xLoc;
			saveGame.data.m_targetLoc = m_targetLoc;
			saveGame.data.m_graveLoc = m_graveLoc;
			saveGame.data.m_jobProgress = m_jobProgress;
			saveGame.data.m_jobLength = m_jobLength;
			saveGame.data.m_accomplishments = m_accomplishments;
			
			saveGame.data.resources = store.resource;
			saveGame.data.enl = Research.ref.enlightenment;
			saveGame.data.inf = Research.ref.infrastructure;
			saveGame.data.prd = Research.ref.productivity;
			
			saveGame.flush();
		}
		
		public function restart() : void
		{
			//no longer used, reload used instead
			stageRef.stage.addEventListener(Event.ENTER_FRAME, eachFrame);
		}
		
		public function dispose() : void
		{
			//market
			for each (var f : Field in holdings)
			{
				f.dispose();
			}
			holdings = [];
			for each (var m : FamilyMeeple in family)
			{
				m.dispose();
			}
			family = [];
			actionMenu.dispose();
			actionMenu = null;
			store.dispose();
			store = null;
			Research.dispose();
			speedButtonx0.removeEventListener(MouseEvent.CLICK, setSpeed0);
			speedButtonx1.removeEventListener(MouseEvent.CLICK, setSpeed1);
			speedButtonx2.removeEventListener(MouseEvent.CLICK, setSpeed2);
			speedButtonx4.removeEventListener(MouseEvent.CLICK, setSpeed4);
			stageRef.removeChild(speedButtonx0);
			stageRef.removeChild(speedButtonx1);
			stageRef.removeChild(speedButtonx2);
			stageRef.removeChild(speedButtonx4);
			quitButton.removeEventListener(MouseEvent.CLICK, returnToMenu);
			stageRef.removeChild(quitButton);
			stageRef.removeChild(skyClip);
			stageRef.removeChild(mountain);
			var nullMessage : MessageBox = new MessageBox(stageRef, "");
			//stageRef.stage.removeEventListener(Event.ENTER_FRAME, eachFrame);
			pi.destroy();
			stageRef = null;
			kongregate = null;
			gameOver = false;
		}
		
		private function addSpeedButtons():void
		{
			gameSpeed = 1;
			
			speedButtonx0 = new x0Button();
			stageRef.addChild(speedButtonx0);
			speedButtonx0.x = 610;
			speedButtonx0.y = 45;
			speedButtonx0.useHandCursor = true;
			speedButtonx0.buttonMode = true;
			speedButtonx0.mouseChildren = false;
			speedButtonx0.addEventListener(MouseEvent.CLICK, setSpeed0);
			speedButtonx0.gotoAndStop(1);
			
			speedButtonx1 = new x1Button();
			stageRef.addChild(speedButtonx1);
			speedButtonx1.x = 610;
			speedButtonx1.y = 70;
			speedButtonx1.useHandCursor = true;
			speedButtonx1.buttonMode = true;
			speedButtonx1.mouseChildren = false;
			speedButtonx1.addEventListener(MouseEvent.CLICK, setSpeed1);
			speedButtonx1.gotoAndStop(2);
			
			speedButtonx2 = new x2Button();
			stageRef.addChild(speedButtonx2);
			speedButtonx2.x = 610;
			speedButtonx2.y = 95;
			speedButtonx2.useHandCursor = true;
			speedButtonx2.buttonMode = true;
			speedButtonx2.mouseChildren = false;
			speedButtonx2.addEventListener(MouseEvent.CLICK, setSpeed2);
			speedButtonx2.gotoAndStop(1);
			
			speedButtonx4 = new x4Button();
			stageRef.addChild(speedButtonx4);
			speedButtonx4.x = 610;
			speedButtonx4.y = 120;
			speedButtonx4.useHandCursor = true;
			speedButtonx4.buttonMode = true;
			speedButtonx4.mouseChildren = false;
			speedButtonx4.addEventListener(MouseEvent.CLICK, setSpeed4);
			speedButtonx4.gotoAndStop(1);
			
			quitButton = new QuitButton();
			stageRef.addChild(quitButton);
			quitButton.x = 16;
			quitButton.y = 12;
			quitButton.addEventListener(MouseEvent.CLICK, returnToMenu);
		}
		
		private function setSpeed0(e:MouseEvent = null):void 
		{
			speedButtonx0.gotoAndStop(2);
			speedButtonx1.gotoAndStop(1);
			speedButtonx2.gotoAndStop(1);
			speedButtonx4.gotoAndStop(1);
			gameSpeed = 0;
		}
		
		private function setSpeed1(e:MouseEvent = null):void 
		{
			speedButtonx0.gotoAndStop(1);
			speedButtonx1.gotoAndStop(2);
			speedButtonx2.gotoAndStop(1);
			speedButtonx4.gotoAndStop(1);
			gameSpeed = 1;
		}
		
		private function setSpeed2(e:MouseEvent = null):void 
		{
			speedButtonx0.gotoAndStop(1);
			speedButtonx1.gotoAndStop(1);
			speedButtonx2.gotoAndStop(2);
			speedButtonx4.gotoAndStop(1);
			gameSpeed = 2;
		}
		
		private function setSpeed4(e:MouseEvent = null):void 
		{
			speedButtonx0.gotoAndStop(1);
			speedButtonx1.gotoAndStop(1);
			speedButtonx2.gotoAndStop(1);
			speedButtonx4.gotoAndStop(2);
			gameSpeed = 4;
		}
		
		private function startFamily():void
		{
			family = [];
			spawnChildThing(null);
		}
		
		private function buildFarm() : void
		{
			holdings = [];
			for (var i : int = 0; i < 13; i++)
			{
				var newField : Field = new Field(stageRef, i * Field.FIELD_WIDTH, store);
				holdings.push(newField);
				newField.addEventListener(GameEvent.ACTION_BUTTON_PRESSED, showActionMenu);
				newField.addEventListener(GameEvent.ACTION_CANCELLED, actionCancelled);
			}
			
			holdings[4].addHouse();
			houseXLoc = 216;
			holdings[12].addSign();
		}
		
		private function buildSky() : void
		{
			skyClip = new SkyClip();
			stageRef.addChild(skyClip);
		}
		
		private function eachFrame(e:Event) : void
		{
			if (!gameOver)
			{
				for (var i : int = 0; i < gameSpeed; i++)
				{
					tickWorld();
					moveFamily();
				}
			}
			else
			{
				skyClip.x = Math.floor(skyClip.x - 1);
				if (skyClip.x <= -2400)
				{
					skyClip.x = 0;
				}
			}
			checkSpeedKeys();
		}
		
		private function checkSpeedKeys():void
		{
			if (pi._keyDown[48])
			{
				setSpeed0();
			}
			if (pi._keyDown[49])
			{
				setSpeed1();
			}
			if (pi._keyDown[50])
			{
				setSpeed2();
			}
			if (pi._keyDown[52])
			{
				setSpeed4();
			}
		}
		
		private function familyHeadingTo(x : int) : int
		{
			var answer : int = 0;
			//returns how many family are walking towards location x
			for each (var f : FamilyMeeple in family)
			{
				if (f.targetLocation == x)
				{
					answer++;
				}
			}
			return answer;
		}
		
		private function generateTaskList() : Array
		{
			var taskList : Array = [];
			for (var i : int = 0; i < holdings.length; i++)
			{
				if (holdings[i].queuedAction != "")
				{
					if (familyHeadingTo(i) == 0)
					{
						taskList.push(i);
					}
				}
			}
			return taskList;
		}
		
		private function moveFamily():void
		{
			var taskList : Array = generateTaskList();
			for each (var member : FamilyMeeple in family)
			{
				member.eachFrame(taskList, holdings);
			}
		}
		
		private function tickWorld() : void
		{
			//2400 frames in a day
			//24 ticks a day
			tickCount++;
			if (tickCount >= 80)
			{
				tickFields();
				store.checkPastures();
			}
			moveSky();
			if (holdings[3].graveArray.length >= 3 && !gameOver)
			{
				//12 dead people
				gameOver = true;
				endGame();
			}
		}
	
		private function tickFields():void
		{
			tickCount = 0;
			for each (var f : Field in holdings)
			{
				f.tick();
			}
		}
		
		private function passYear():void
		{
			currentYear++;
			for each (var m : FamilyMeeple in family)
			{
				m.passYear(store.resource[Store.HEALTH], stageRef);
			}
			for (var i : int = family.length-1; i >= 0; i--)
			{
				if (family[i].dead)
				{
					kill(i, 320);
				}
			}
		}
		
		private function moveSky() : void
		{
			skyClip.x = Math.floor(skyClip.x - 1);
			if (skyClip.x <= -2400)
			{
				skyClip.x = 0;
			}
			if (Math.floor(-skyClip.x) == 1200 - houseXLoc || Math.floor(-skyClip.x) == 1750 - houseXLoc || Math.floor(-skyClip.x) == 2300 - houseXLoc)
			{
				submitStats();
				passYear();
			}
			if (Math.floor(-skyClip.x) == 550 - houseXLoc) 
			{
				if (store.resource[Store.FAMILY_SIZE] > 0)
				{
					eat();
				}
				else
				{
					newAdoption();
				}
			}
			if (Math.floor( -skyClip.x) == 1750 - houseXLoc && gameMode == HARDCORE)
			{
				eat();
			}
			skyClip.mouseChildren = false;
			skyClip.addEventListener(MouseEvent.CLICK, deselect);
		}
		
		private function eat():void
		{
			var hunger : int = store.resource[Store.FAMILY_SIZE];
			var meat_eaten : int = 0;
			var veg_eaten : int = 0;
			var bread_eaten : int = 0;
			var nextAdjustHeight : int = 340;
			if (store.totalFood() < hunger)
			{
				//starvation
				meat_eaten = store.resource[Store.MEAT];
				veg_eaten = store.resource[Store.VEG];
				bread_eaten = store.resource[Store.BREAD];
				hunger -= store.totalFood();
				//a meeple has starved
				if (store.resource[Store.FAMILY_SIZE] == 1 && family[0].age < 25)
				{
					//don't kill the last meeple unless he is rather old
					hunger += 2;
					var notification : MessageBox = new MessageBox(stageRef, "Starvation!\n" + family[0].name + " is very hungry and lonely");
				}
				else
				{
					killOldest(nextAdjustHeight -=20);
				}
			}
			else while (hunger > 0)
			{
				if (store.resource[Store.MEAT] > meat_eaten)
				{
					meat_eaten++;
					hunger--;
				}
				if (store.resource[Store.BREAD] > bread_eaten && hunger > 0)
				{
					bread_eaten++;
					hunger--;
				}
				if (store.resource[Store.VEG] > veg_eaten && hunger > 0)
				{
					veg_eaten++;
					hunger--;
				}
			}
			var healthBonus : int = -2;
			if (bread_eaten > 0)
			{
				healthBonus++;
			}
			if (veg_eaten > 0)
			{
				healthBonus++;
			}
			if (meat_eaten > 0)
			{
				healthBonus++;
			}
			if (Research.ref.enlightenment > 3)
			{
				healthBonus++;
			}
			healthBonus -= hunger;
			if (healthBonus != 0)
			{
				store.adjustStores(Store.HEALTH, healthBonus, new Point(houseXLoc, nextAdjustHeight -= 20));
			}
			
			if (bread_eaten != 0)
			{
				store.adjustStores(Store.BREAD, -bread_eaten, new Point(houseXLoc, nextAdjustHeight -= 20));
			}
			if (veg_eaten != 0)
			{
				store.adjustStores(Store.VEG, -veg_eaten, new Point(houseXLoc, nextAdjustHeight -= 20));
			}
			if (meat_eaten != 0)
			{
				store.adjustStores(Store.MEAT, -meat_eaten, new Point(houseXLoc, nextAdjustHeight -= 20));
			}
		}
		
		private function killOldest(nextAdjustHeight : int) : void
		{
			var oldestSoFar : int = 1;
			var likelyVictim : int = 0;
			var i : int;
			//find the eldest
			for (i = 0; i < family.length; i++) 
			{
				if (family[i].age > oldestSoFar)
				{
					oldestSoFar = family[i].age;
					likelyVictim = i;
				}
			}
			
			var notification : MessageBox = new MessageBox(stageRef, "Starvation!\n" + family[likelyVictim].name + " has passed away");
			kill(likelyVictim, nextAdjustHeight);
		}
		
		private function kill(meepleNumber : int, nextAdjustHeight : int) : void
		{
			//trace ('killing ' + meepleNumber);
			family[meepleNumber].diedDate = currentYear;
			family[meepleNumber].dead = true;
			family[meepleNumber].dispatch(stageRef);
			family[meepleNumber].removeEventListener(GameEvent.JOB_FINISHED, jobFinished);
			store.adjustStores(Store.FAMILY_SIZE, -1, new Point(houseXLoc, nextAdjustHeight));
			
			//bury them
			if (gameMode != SANDBOX)
			{
				var burialField : int = 5;
				for (var i : int = 3; i >= 0; i--)
				{
					if (holdings[i].graveArray.length < 3)
					{
						burialField = i;
					}
				}
				family[meepleNumber].graveLocation = burialField;
				holdings[burialField].bury(family[meepleNumber]);
			}
			
			//widow them
			for each (var f : FamilyMeeple in family)
			{
				if (f.spouseName == family[meepleNumber].name)
				{
					f.married = false;
				}
			}
			
			family.splice(meepleNumber, 1);
		}
		
		private function deselect(e:MouseEvent):void 
		{
			actionMenu.destroyMenu();
		}
		
		private function showActionMenu(e:GameEvent):void 
		{
			var field : Field = Field(e.currentTarget);
			actionMenu.showMenu(field);
		}
		
		private function actionCancelled(e:GameEvent):void 
		{
			var field : Field = Field(e.currentTarget);
			for each (var f : FamilyMeeple in family)
			{
				f.checkJobCancel(field.fieldNumber());
			}
		}
		
		private function jobFinished(e:GameEvent):void 
		{
			var meeple : FamilyMeeple = FamilyMeeple(e.currentTarget);
			var field : Field = holdings[meeple.targetLocation];
			if (field.queuedAction == FamilyMeeple.GROW_FAMILY)
			{
				spawnChildThing(meeple);
			}
			meeple.recordJobCompletion(field.queuedAction);
			field.jobComplete();
		}
		
		private function spawnChildThing(creator : FamilyMeeple):void
		{
			var r : int = 1 + Math.floor(Math.random() * 20);
			var child : FamilyMeeple = new FamilyMeeple(stageRef, houseXLoc, r);
			child.addEventListener(GameEvent.JOB_FINISHED, jobFinished);
			family.push(child);
			child.bornDate = currentYear - 16;
			store.adjustStores(Store.FAMILY_SIZE, 1, new Point (houseXLoc, 300));
			
			if (creator == null)
			{
				try
				{
					child.parentName = "Founder";
					child.name = kongregate.services.getUsername();
				}
				catch (error : * )
				{
					//child.name = "Guest";
				}
				
			}
			else if (!creator.married)
			{
				//get married
				creator.spouseName = child.name;
				child.spouseName = creator.name;
				child.married = true;
				creator.married = true;
				child.accomplishments[FamilyMeeple.TIMES_MARRIED]++;
				creator.accomplishments[FamilyMeeple.TIMES_MARRIED]++;
				var wedding : MessageBox = new MessageBox(stageRef, "Wedding! " + creator.name + " has attracted a new spouse, " + child.name + ", who has joined the family.");
			}
			else
			{
				//have a child
				child.parentName = creator.name + " and " + creator.spouseName;
				var birth : MessageBox = new MessageBox(stageRef, child.parentName + " have successfully raised a new child. Today " + child.name + " has come of age.");
			}
			
		}
		
		private function newAdoption():void
		{
			var r : int = 1 + Math.floor(Math.random() * 20);
			var child : FamilyMeeple = new FamilyMeeple(stageRef, houseXLoc, r);
			child.addEventListener(GameEvent.JOB_FINISHED, jobFinished);
			family.push(child);
			child.bornDate = currentYear - 16;
			store.adjustStores(Store.FAMILY_SIZE, 1, new Point (houseXLoc, 300));
			child.parentName = "distant relative.";
			var birth : MessageBox = new MessageBox(stageRef, "A distant relative, " + child.name + ", has inherited the farm.");
		}
		
		
		private function submitStats() : void
		{
			save(saveGameRef);
			var totalAge : int = 0;
			var totalTasks : int = 0;
			for each (var m : FamilyMeeple in family)
			{
				totalAge += m.age;
				totalTasks += m.accomplishments[FamilyMeeple.JOBS_COMPLETED];
			}
			for each (var f : Field in holdings)
			{
				for each (var g : FamilyMeeple in f.meeplesInTheGrave)
				{
					totalAge += g.age;
					totalTasks += g.accomplishments[FamilyMeeple.JOBS_COMPLETED];
				}
			}
			if (gameMode != SANDBOX)
			{
				kongregate.stats.submit ("TotalAge", totalAge);
				kongregate.stats.submit ("TotalTasks", totalTasks);
				kongregate.stats.submit ("TechLevel", Research.ref.techPercent());
				kongregate.stats.submit ("TotalWealth", store.totalWealth());
				kongregate.stats.submit ("YearReached", currentYear);
			}
		}
		
		private function endGame():void
		{
			gameEndClip = new GameOverClip();
			stageRef.addChild(gameEndClip);
			gameEndClip.gold.text = store.resource[Store.GOLD].toString();
			gameEndClip.grain.text = store.resource[Store.GRAIN].toString();
			gameEndClip.wood.text = store.resource[Store.WOOD].toString();
			gameEndClip.flour.text = store.resource[Store.FLOUR].toString();
			gameEndClip.knowledge.text = store.resource[Store.KNOWLEDGE].toString();
			gameEndClip.meat.text = store.resource[Store.MEAT].toString();
			gameEndClip.bread.text = store.resource[Store.BREAD].toString();
			gameEndClip.veg.text = store.resource[Store.VEG].toString();
			gameEndClip.family.text = store.resource[Store.FAMILY_SIZE].toString();
			gameEndClip.health.text = store.resource[Store.HEALTH].toString();
			
			var totalAge : int = 0;
			var totalTasks : int = 0;
			for each (var m : FamilyMeeple in family)
			{
				totalAge += m.age;
				totalTasks += m.accomplishments[FamilyMeeple.JOBS_COMPLETED];
			}
			for each (var f : Field in holdings)
			{
				for each (var g : FamilyMeeple in f.meeplesInTheGrave)
				{
					totalAge += g.age;
					totalTasks += g.accomplishments[FamilyMeeple.JOBS_COMPLETED];
				}
			}
			
			gameEndClip.tech.text = "Technology: " + Research.ref.techPercent().toString() + "%";
			gameEndClip.totalAge.text = "Combined family age: " + totalAge.toString();
			gameEndClip.tasks.text = "Tasks accomplished: " + totalTasks.toString();
			gameEndClip.wealth.text = "Material wealth: " + store.totalWealth();
			gameEndClip.year.text = "Ending year: " + currentYear.toString() + "AD";
			
			submitStats();
			gameEndClip.OkButton.addEventListener(MouseEvent.CLICK, gameWon);
		}
		
		private function gameWon(e:MouseEvent):void 
		{
			gameEndClip.OkButton.removeEventListener(MouseEvent.CLICK, gameWon);
			gameEndClip.parent.removeChild(gameEndClip);
			gameEndClip = null;
			returnToMenu();
		}
		
		
	}

}