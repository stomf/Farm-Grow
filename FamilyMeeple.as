package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class FamilyMeeple extends EventDispatcher
	{
		public static const GROW_FAMILY : String = "Grow Family";
		public static const PLOUGH_FIELD : String = "Plough Field";
		public static const SOW_GRAIN : String = "Sow Grain";
		public static const PLANT_TREES : String = "Plant Trees";
		public static const PLANT_VEG : String = "Plant Veg";
		public static const HARVEST : String = "Harvest";
		public static const GO_TO_MARKET : String = "Market";
		public static const GO_TO_SCHOOL : String = "School"
		public static const GO_TO_WORK : String = "Labour";
		public static const MOURN_THE_DEAD : String = "Mourn Dead";
		public static const CHOP_TREES_1 : String = "Chop Trees 1";
		public static const CHOP_TREES_3 : String = "Chop Trees 3";
		public static const CHOP_TREES_5 : String = "Chop Trees 5";
		public static const RESEARCH : String = "Research";
		public static const BAKE_BREAD : String = "Bake Bread";
		public static const MILL_FLOUR : String = "Mill Flour";
		public static const BUILD_MILL : String = "Build Mill";
		public static const BUILD_WELL : String = "Build Well";
		public static const BUILD_FENCES : String = "Build Pen";
		public static const COOK_PIG : String = "Cook Pig";
		public static const COOK_SHEEP : String = "Cook Sheep";
		public static const COOK_COW : String = "Cook Cow";
		public static const DEMOLISH : String = "Clear Building";
		public static const DRAW_WATER : String = "Draw Water";
		
		private static const FIELDS_PLOUGHED : int = 0;
		private static const FIELDS_SOWN : int = 1;
		private static const FIELDS_HARVESTED : int = 2;
		private static const LESSONS_ATTENDED : int = 3;
		private static const MEALS_EATEN : int = 4;
		public static const TIMES_MARRIED : int = 5;
		public static const JOBS_COMPLETED : int = 6;
		private static const STEPS_WALKED : int = 7;
		private static const TREES_CUT : int = 8;
		private static const BUILDINGS_RAISED : int = 9;
		private static const ANIMALS_BUTCHERED : int = 10;
		
		public static const WORK_RATE : Number = 1.25;
		
		private static const nameList : Array = ["Tom", "Huw", "Daniel", "Skippy", "Shirelindra", "Hektik", "Erickia", "Macie", "Windo", "Jason", "Matt", "Brandon", "Jupiter", "Blue", "Clobster", "Felix", "Eman", "Wolf",
		"Polochavez", "Billy", "Chase", "Godzilla", "Dude", "Promune", "Hurricain", "Canfield", "Chila", "Pedro", "Hannah", "Tukkun", "Jesse", "Chris", "Julien", "Araym", "Chicken", "Eddozook", "Inen", "Alex", "Jill", "Willow", 
		"Sean", "Samster", "Tony", "Fierce", "Kris", "Brog", "Tara", "Balders", "Satan", "Abaker", "Planx", "Monkey", "Rattus", "Jonathan", "Rival", "Chuck", "Ian", "Kevin", "Ponylips", "Ben", "Queex", "Devil", "Imi",
		"Ehrine", "Johannas", "Joseph", "Xander", "Dragonrider", "Emily", "Gnome", "Jumbo", "Xarrion", "Zayzay", "Guardian", "Orandze", "Llama", "Moshdef", "Lucidius", "Danny", "Lobster", "Solsund", "Shadow", "Erlend",
		"Janova", "Bob", "Halysia", "Truefire", "Senekis", "Jimbo", "Nerdook", "Sarah", "Jane", "Annah", "Shay", "Roxanne", "Helen", "Fiona", "Nom Nom", "Zara", "Claire", "Rowina", "Emma", "Brooke", "Izzy", "Beccy", "Jo"];
		
		public var clip : MovieClip;
		public var targetLocation : int;
		public var jobProgress : Number;
		public var jobLength : int;
		public var name : String;
		public var age : int;
		public var dead : Boolean;
		public var bornDate : int;
		public var diedDate : int;
		public var spouseName : String;
		public var parentName : String;
		public var married : Boolean;
		private var statBlockClip : MovieClip;
		public var graveLocation : int;
		public var colour : int;
		
		//accomplishments
		public var accomplishments : Array;
		
		public function FamilyMeeple(parent : DisplayObjectContainer, houseLoc : int, newColour : int) : void
		{
			accomplishments = [0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0];
			
			colour = newColour;
			clip = getNewClip();
			parent.addChild(clip);
			clip.x = houseLoc;
			clip.y = 340;
			clip.visible = false;
			
			targetLocation = -1; //no job
			jobProgress = 0.0;
			graveLocation = 0;
			name = nameList[Math.floor(Math.random() * nameList.length)];
			age = 16;
			dead = false;
			diedDate = 0;
			spouseName = "";
			parentName = "";
			married = false;
			
			clip.addEventListener(MouseEvent.ROLL_OVER, mouseOverMeeple);
			clip.addEventListener(MouseEvent.ROLL_OUT, mouseLeftMeeple);
		}
		
		public function dispose() : void
		{
			clip.removeEventListener(MouseEvent.ROLL_OVER, mouseOverMeeple);
			clip.removeEventListener(MouseEvent.ROLL_OUT, mouseLeftMeeple);
			if (statBlockClip != null)
			{
				mouseLeftMeeple();
			}
			clip.parent.removeChild(clip);
			accomplishments = [];
		}
		
		public function dispatch(stageRef : DisplayObjectContainer) : void
		{
			//this person has died
			clip.visible = false;
			//remove clip when game terminated; the object will remain attached to a gravestone
		}
		
		
		private function getNewClip() : MovieClip
		{
			var answer : MovieClip;
			if (colour == 20)
			{
				answer =  new MeepleClip1();
			}
			if (colour <= 1)
			{
				answer =  new MeepleClip2();
			}
			if (colour == 2)
			{
				answer =  new MeepleClip3();
			}
			if (colour == 3)
			{
				answer =  new MeepleClip4();
			}
			if (colour == 4)
			{
				answer =  new MeepleClip5();
			}
			if (colour == 5)
			{
				answer =  new MeepleClip6();
			}
			if (colour == 6)
			{
				answer =  new MeepleClip7();
			}
			if (colour == 7)
			{
				answer =  new MeepleClip8();
			}
			if (colour == 8)
			{
				answer =  new MeepleClip9();
			}
			if (colour == 9)
			{
				answer =  new MeepleClip10();
			}
			if (colour == 10)
			{
				answer =  new MeepleClip11();
			}
			if (colour == 11)
			{
				answer =  new MeepleClip12();
			}
			if (colour == 12)
			{
				answer =  new MeepleClip13();
			}
			if (colour == 13)
			{
				answer =  new MeepleClip14();
			}
			if (colour == 14)
			{
				answer =  new MeepleClip15();
			}
			if (colour == 15)
			{
				answer =  new MeepleClip16();
			}
			if (colour == 16)
			{
				answer =  new MeepleClip17();
			}
			if (colour == 17)
			{
				answer =  new MeepleClip18();
			}
			if (colour == 18)
			{
				answer =  new MeepleClip19();
			}
			if (colour == 19)
			{
				answer =  new MeepleClip20();
			}
			
			return answer;	
		}
		
		private function mouseLeftMeeple(e:MouseEvent = null):void 
		{
			statBlockClip.parent.removeChild(statBlockClip);
			statBlockClip = null;
		}
		
		private function mouseOverMeeple(e:MouseEvent):void 
		{
			statBlockClip = new MeepleStatsClip();
			statBlockClip.mouseChildren = false;
			clip.parent.addChild(statBlockClip);
			
			statBlockClip.meepleName.text = name;
			var familyTree : String = "";
			if (parentName == "Founder")
			{
				familyTree = "Founder of the family. ";
			}
			else if (parentName != "")
			{
				familyTree = "Child of " + parentName + ". ";
			}
			if (spouseName != "")
			{
				familyTree += "Spouse of " + spouseName + ".";
			}
			statBlockClip.familyTree.text = familyTree;
			statBlockClip.dateNote.text = "Born " + bornDate + "AD";
			statBlockClip.age.text = "Age : " + age;
		}
		
		private function getMoveSpeed() : Number
		{
			if (Research.ref.infrastructure > 1)
			{
				return 1.75;
			}
			else
			{
				return 1.4;
			}
		}
		
		public function recordJobCompletion(task : String) : void
		{
			accomplishments[JOBS_COMPLETED]++;
			if (task == PLOUGH_FIELD)
			{
				accomplishments[FIELDS_PLOUGHED]++;
			}
			if (task == SOW_GRAIN || task == PLANT_VEG || task == PLANT_TREES)
			{
				accomplishments[FIELDS_SOWN]++;
			}
			if (task == HARVEST)
			{
				accomplishments[FIELDS_HARVESTED]++;
			}
			if (task == GO_TO_SCHOOL)
			{
				accomplishments[LESSONS_ATTENDED]++;
			}
			if (task.substr(0, 10) == "Chop Trees")
			{
				accomplishments[TREES_CUT] += 3;
			}
			if (task == BUILD_FENCES || task == BUILD_MILL || task == BUILD_WELL)
			{
				accomplishments[BUILDINGS_RAISED] += 1;
			}
			if (task == COOK_COW || task == COOK_PIG || task == COOK_SHEEP)
			{
				accomplishments[ANIMALS_BUTCHERED] += 1;
			}
		}
		
		public function returnBestAccomplishments() : String
		{
			//trace (accomplishments);
			var answer : String = "";
			var notability : Array = [1, 1, 1.1, 1.5, 0.2, 20, 0.3, 0.003, 0.2, 5, 2];
			var rankArray : Array = [];
			
			var i : int;
			var bestValue : Number = 0;
			for (i = 0; i < accomplishments.length; i++)
			{
				if (notability[i] * accomplishments[i] >= bestValue)
				{
					rankArray[0] = i;
					bestValue = notability[i] * accomplishments[i];
				}
			}
			bestValue = 0;
			for (i = 0; i < accomplishments.length; i++)
			{
				if (notability[i] * accomplishments[i] >= bestValue && rankArray[0] != i)
				{
					rankArray[1] = i;
					bestValue = notability[i] * accomplishments[i];
				}
			}
			bestValue = 0;
			for (i = 0; i < accomplishments.length; i++)
			{
				if (notability[i] * accomplishments[i] >= bestValue && rankArray[0] != i && rankArray[1] != i)
				{
					rankArray[2] = i;
					bestValue = notability[i] * accomplishments[i];
				}
			}
			
			//trace (rankArray);
			for each (i in rankArray)
			{
				
				switch (i)
				{
					case FIELDS_PLOUGHED:
						answer += accomplishments[FIELDS_PLOUGHED].toString() + " fields ploughed.\n";
					break;
					case FIELDS_HARVESTED:
						answer += accomplishments[FIELDS_HARVESTED].toString() + " harvests gathered.\n";
					break;
					case FIELDS_SOWN:
						answer += accomplishments[FIELDS_SOWN].toString() + " fields sown.\n";
					break;
					case MEALS_EATEN:
						answer += accomplishments[MEALS_EATEN].toString() + " years survived.\n";
					break;
					case TIMES_MARRIED:
						answer += (1 + accomplishments[TIMES_MARRIED]).toString() + " times married.\n";
					break;
					case JOBS_COMPLETED:
						answer += accomplishments[JOBS_COMPLETED].toString() + " tasks completed.\n";
					break;
					case STEPS_WALKED:
						answer += accomplishments[STEPS_WALKED].toString() + " steps walked.\n";
					break;
					case TREES_CUT:
						answer += accomplishments[TREES_CUT].toString() + " trees felled.\n";
					break;
					case BUILDINGS_RAISED:
						answer += accomplishments[BUILDINGS_RAISED].toString() + " buildings raised.\n";
					break;
					case ANIMALS_BUTCHERED:
						answer += accomplishments[ANIMALS_BUTCHERED].toString() + " animals butchered.\n";
					break;
					case LESSONS_ATTENDED:
						answer += accomplishments[LESSONS_ATTENDED].toString() + " classes attended.\n";
					break;
				}
				//trace (i, accomplishments[i].toString(), answer);
			}
			return answer;
		}
		
		public function eachFrame(taskList : Array, holdings : Array) : void
		{
			if (targetLocation == -1)
			{
				if (taskList.length == 0)
				{
					//walk to house
					walkTo(4);
				}
				else
				{
					findJob(taskList, holdings);
				}
			}
			else if (jobProgress == 0)
			{
				walkTo(targetLocation);
			}
			else
			{
				doJob();
			}
		}
		
		public function passYear(healthLevel : int, stageRef : DisplayObjectContainer) : void
		{
			if (Math.random() < getDeathChance(healthLevel))
			{
				dead = true;
				if (Math.random() > getDeathChance(0))
				{
					var notificationI : MessageBox = new MessageBox(stageRef, name + " has died from an illness.");
				}
				else
				{
					var notificationO : MessageBox = new MessageBox(stageRef, name + " has died of old age.");
				}
			}
			else
			{
				age++;
				accomplishments[MEALS_EATEN]++;
			}
		}
		
		private function getDeathChance(healthLevel : int) : Number
		{
			var deathChance : Number = (age * 2 - 50);
			//trace (age, deathChance);
			deathChance -= (healthLevel / 2.5);
			//trace (deathChance);
			if (age < 25 || deathChance < 0)
			{
				deathChance = 0;
			}
			deathChance *= 0.005;
			deathChance *= deathChance;
			//trace ('pre adjust deathchance: ' + deathChance);
			if (deathChance > 0.8)
			{
				deathChance = 0.8;
			}
			//trace ("age", age, "health", healthLevel, "deathChance", deathChance);
			return deathChance;
		}
		
		private function doJob() : void
		{
			var minX : int = fieldToX(targetLocation) - (Field.FIELD_WIDTH / 4);
			var maxX : int = fieldToX(targetLocation) + (Field.FIELD_WIDTH / 4);
			if (clip.scaleX > 0)
			{
				if (clip.x > maxX)
				{
					clip.scaleX = -1;
				}
				else
				{
					clip.x += WORK_RATE/1.4;
				}
			}
			else
			{
				if (clip.x < minX)
				{
					clip.scaleX = 1;
				}
				else
				{
					clip.x -= WORK_RATE/1.4;
				}
			}
			jobProgress += WORK_RATE;
			if (jobProgress >= jobLength)
			{
				jobFinshed();
			}
		}
		
		private function jobFinshed():void
		{
			dispatchEvent(new GameEvent(GameEvent.JOB_FINISHED));
			targetLocation = -1;
			jobProgress = 0;
		}
		
		private function walkTo(loc : int) : void
		{
			if (fieldToX(loc) < clip.x)
			{
				clip.x -= getMoveSpeed();
				clip.scaleX = -1;
				if (clip.visible)
				{
					accomplishments[STEPS_WALKED]++;
				}
			}
			else 
			{
				clip.x += getMoveSpeed();
				clip.scaleX = 1;
				if (clip.visible)
				{
					accomplishments[STEPS_WALKED]++;
				}
			}
			if (Math.abs(fieldToX(loc) - clip.x) < getMoveSpeed())
			{
				//reached target location
				if (targetLocation == -1)
				{
					//in house now
					clip.visible = false;
				}
				else
				{
					//start work
					jobProgress = 1.0;
				}
			}
		}
		
		private function findJob(taskList : Array, holdings : Array) : void
		{
			//find closest job.
			var bestJob : int = -1;
			var bestDistance : int = 100;
			for (var i : int = 0; i < taskList.length; i++)
			{
				var thisJobDistance = Math.abs(fieldLoc() - taskList[i]);
				if (thisJobDistance < bestDistance)
				{
					bestJob = i;
					bestDistance = thisJobDistance;
				}
			}
			
			targetLocation = taskList[bestJob];
			//trace ('assigned job in field ' + targetLocation + ", tasklist = " + taskList);
			taskList.splice(bestJob, 1);
			clip.visible = true;
			
			var task : String = Field(holdings[targetLocation]).queuedAction;

			jobLength = 256;
			if (task == PLANT_VEG)
			{
				jobLength *= 1.5;
			}
			if (task == GO_TO_SCHOOL)
			{
				jobLength *= 3;
			}
			if (task == GO_TO_WORK)
			{
				jobLength *= 3;
			}
			if (task == BAKE_BREAD || task == MILL_FLOUR)
			{
				jobLength *= 2;
			}
			if (task == BAKE_BREAD && Research.ref.infrastructure > 6)
			{
				jobLength *= 0.5;
			}
			if ((task == PLANT_VEG || task == SOW_GRAIN || task == PLOUGH_FIELD) && Research.ref.productivity > 1)
			{
				jobLength *= 0.7;
			}
		}
		
		private function fieldLoc() : int
		{
			var answer : int = Math.floor(clip.x / Field.FIELD_WIDTH);
			return answer;
		}
		
		private function fieldToX(field : int) : int
		{
			var answer : int = (field + 0.5) * Field.FIELD_WIDTH;
			if (field == 12) //go to town!
			{
				answer += 2*Field.FIELD_WIDTH;
			}
			return answer;
		}
		
		public function checkJobCancel(fieldNumber : int) : void
		{
			//player has just cancelled the job in field fieldNumber
			//if this meeple is assigned to the job, it needs to be cancelled here too
			if (targetLocation == fieldNumber)
			{
				//trace ('my job cancelled');
				jobProgress = 0;
				targetLocation = -1;
			}
		}
		
	} //end class

}