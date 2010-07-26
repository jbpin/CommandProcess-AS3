package org.npcommand.command
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.npcommand.interfaces.INativeProcessCommand;
	import org.osflash.signals.Signal;

	public class NativeProcessCommand implements INativeProcessCommand 
	{
	
		private var _commandName:String;
		private var _args:ArrayCollection;
		private var _workingDirectory:File;

		private var _output:Signal;
		private var _error:Signal;
		private var _exit:Signal;
		
		public function NativeProcessCommand()
		{
			_args = new ArrayCollection();
			_output = new Signal(Object);
			_error = new Signal(Object);
			_exit = new Signal(Object);
		}
		
		
		public function get workingDirectory():File
		{
			return _workingDirectory;
		}

		public function set workingDirectory(value:File):void
		{
			_workingDirectory = value;
		}

		public function get args():ArrayCollection
		{
			return _args;
		}

		public function set args(value:ArrayCollection):void
		{
			_args = value;
		}

		public function get commandName():String
		{
			return _commandName;
		}

		public function set commandName(value:String):void
		{
			_commandName = value;
		}

		public function get exit():Signal
		{
			return _exit;
		}
		
		public function get error():Signal
		{
			return _error;
		}
		
		public function get output():Signal
		{
			return _output;
		}

		
		
		public function getArgs():Vector.<String>{
			var rargs:Vector.<String> = new Vector.<String>;
			if(_commandName != null){
				rargs.push(_commandName);
			}
			for each(var opt:Object in args)
			{
				rargs.push(opt);
			}
			trace(rargs.toString());
			return rargs;
		}
		
	}
}