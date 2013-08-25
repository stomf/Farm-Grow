package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.navigateToURL;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.*;
	
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class Farm extends MovieClip 
	{
		private var gameScreen : MovieClip; 
		private var menuPage : MovieClip;
		private var game : GameClass;
		public var kongregate : * ;
		private var saveGame : SharedObject;
		
		public function Farm() : void
		{
			stage.showDefaultContextMenu = false;
			stage.focus = stage;
			stage.stageFocusRect = false;
			stage.tabChildren = false;
			loadKong();
		}
		
		public function begin() : void
		{
			menuPage = new menuPageClip();
			addChild(menuPage);
			if (this.root.loaderInfo.url.indexOf("kongregate.com") != -1) //change != to == to turn on site locking code!
			{
				var blockBox : MovieClip = new BlockBox();
				stage.addChild(blockBox);
			}
			else
			{
				gameScreen = new MovieClip;
				addChild(gameScreen);
				menuPage.startGameButton.addEventListener(MouseEvent.CLICK, startNormalGame);
				stage.addEventListener(Event.ENTER_FRAME, SoundManager.eachFrame);
				menuPage.cgLogo.addEventListener(MouseEvent.CLICK, gotoHomePage);
				SoundManager.addMusicButton(stage);
				
				saveGame = SharedObject.getLocal("Farm2Grow");
				if (saveGame.data.exists)
				{
					menuPage.continueGameButton.visible = true;
				}
				else
				{
					menuPage.continueGameButton.visible = false;
				}
				menuPage.continueGameButton.addEventListener(MouseEvent.CLICK, continueGame);
				menuPage.hardcoreButton.addEventListener(MouseEvent.ROLL_OVER, overHardcore);
				menuPage.hardcoreButton.addEventListener(MouseEvent.ROLL_OUT, clearTipText);
				menuPage.sandboxButton.addEventListener(MouseEvent.ROLL_OVER, overSandBox);
				menuPage.sandboxButton.addEventListener(MouseEvent.ROLL_OUT, clearTipText);
				menuPage.sandboxButton.addEventListener(MouseEvent.CLICK, launchSandbox);
				menuPage.hardcoreButton.addEventListener(MouseEvent.CLICK, launchHardcore);
			}
		}
	
		private function overHardcore(e:MouseEvent):void 
		{
			menuPage.tipText.text = "Want a challenge?";
		}
		
		private function clearTipText(e:MouseEvent):void 
		{
			menuPage.tipText.text = "";
		}
		
		private function overSandBox(e:MouseEvent):void 
		{
			menuPage.tipText.text = "No gravestones, game continues forever, no highscores";
		}
		
		private function continueGame(e:MouseEvent):void 
		{
			/*if (game != null)
			{
				SoundManager.gameRunning = true;
				SoundManager.bootMusic();
				gameScreen.visible = true;
				menuPage.visible = false;
				game.restart();
			}
			else*/ if (saveGame.data.exists)
			{
				SoundManager.gameRunning = true;
				SoundManager.bootMusic();
				gameScreen.visible = true;
				menuPage.visible = false;
				game = GameClass.reload(saveGame, gameScreen, kongregate);
				game.addEventListener(GameEvent.GAME_SUSPENDED, reopenMenu);
			}
		}
		
		private function reopenMenu(e:GameEvent):void 
		{
			game.save (saveGame);
			game.dispose();
			game.removeEventListener(GameEvent.GAME_SUSPENDED, reopenMenu);
			game = null;
			
			SoundManager.stopMusic();
			SoundManager.gameRunning = false;
			menuPage.visible = true;
			gameScreen.visible = false;
			menuPage.continueGameButton.visible = true;
		}
		
		private function prepGame() : void
		{
			//kill save
			saveGame.data.exists = false;
			saveGame.flush();
			
			menuPage.visible = false;
			SoundManager.gameRunning = true;
			SoundManager.bootMusic();
			
			if (game != null)
			{
				game.dispose();
				game.removeEventListener(GameEvent.GAME_SUSPENDED, reopenMenu);
				game = null;
			}
			gameScreen.visible = true;
		}
		
		private function launchSandbox(e:MouseEvent):void 
		{
			prepGame();
			game = new GameClass(gameScreen, kongregate, true, saveGame, GameClass.SANDBOX);
			game.addEventListener(GameEvent.GAME_SUSPENDED, reopenMenu);
		}
		
		private function launchHardcore(e:MouseEvent):void 
		{
			prepGame();
			game = new GameClass(gameScreen, kongregate, true, saveGame, GameClass.HARDCORE);
			game.addEventListener(GameEvent.GAME_SUSPENDED, reopenMenu);
		}
		
		
		private function startNormalGame(e:MouseEvent):void 
		{
			prepGame();
			game = new GameClass(gameScreen, kongregate, true, saveGame, GameClass.NORMAL);
			game.addEventListener(GameEvent.GAME_SUSPENDED, reopenMenu);
		}
		
		function gotoHomePage(event:MouseEvent):void
		{
			var targetURL:URLRequest = new URLRequest("http://www.curiousgaming.co.uk");
			navigateToURL(targetURL);
		}
		
		
		public function loadKong() : void
		{
			// Pull the API path from the FlashVars
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
			 
			// The API path. The "shadow" API will load if testing locally.
			var apiPath:String = paramObj.kongregate_api_path ||
			  "http://www.kongregate.com/flash/API_AS3_Local.swf";
			 
			// Allow the API access to this SWF
			Security.allowDomain(apiPath);
			 
			// Load the API
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			this.addChild(loader);	
		}
		
		function loadComplete(event:Event):void
		{
			// Save Kongregate API reference
			kongregate = event.target.content;
		 
			// Connect to the back-end
			kongregate.services.connect();
		}
		
		
	} //end class
}