package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	/**
	 * ...
	 * @author tom fraser (curiousGaming)
	 */
	public class SoundManager
	{
		public static var soundVolume : Number = 1.0;
		private static var soundList : Array = [];
		private static var musicChannel : SoundChannel = new SoundChannel();
		private static var musicOn : Boolean = true;
		public static var musicButton : MovieClip;
		public static var gameRunning : Boolean = false;
		
		public function SoundManager() : void
		{
			
		}
		
		public static function addMusicButton(stageRef : DisplayObjectContainer) : void
		{
			musicButton = new MusicButton();
			stageRef.addChild(musicButton);
			musicButton.x = 610;
			musicButton.y = 15;
			musicButton.useHandCursor = true;
			musicButton.buttonMode = true;
			musicButton.addEventListener(MouseEvent.CLICK, SoundManager.toggleMusic);
			musicButton.gotoAndStop(1);
		}
		
		public static function bootMusic() : void
		{
			//start music if not already playing AND music is on
			if (musicOn && gameRunning)
			{
				var track : BackMusic = new BackMusic();
				musicChannel = track.play();
				musicChannel.addEventListener(Event.SOUND_COMPLETE, musicFinished);
			}
		}
		
		private static function musicFinished(e:Event):void 
		{
			musicChannel.removeEventListener(Event.SOUND_COMPLETE, musicFinished);
			var track : BackMusic = new BackMusic();
			musicChannel = track.play();
			musicChannel.addEventListener(Event.SOUND_COMPLETE, musicFinished);
		}
		
		public static function stopMusic() : void
		{
			if (musicOn)
			{
				try
				{
					musicChannel.removeEventListener(Event.SOUND_COMPLETE, musicFinished);
				}
				catch (err : Error)
				{
					trace (err.errorID);
				}
				musicChannel.stop();
			}
			
		}
		
		public static function toggleMusic(e : Event = null) : void
		{
			if (musicOn)
			{
				stopMusic();
				musicOn = false;
				musicButton.gotoAndStop(2);
			}
			else
			{
				musicOn = true;
				bootMusic();
				musicButton.gotoAndStop(1);
			}
		}
		
		public static function eachFrame(e : Event = null) : void
		{
			//play sounds on list
			if (musicOn)
			{
				var trans:SoundTransform = new SoundTransform(soundVolume, 0);
				for each (var sound : Class in soundList)
				{
					(new sound()).play(0,1,trans);
				}
			}
			soundList = [];
		}
		
		public static function addSound(sound : Class):void
		{
			//add sound to list, if not duplicated
			if (soundList.indexOf(sound) == -1)
			{
				soundList.push(sound);
			}
		}
	}
}