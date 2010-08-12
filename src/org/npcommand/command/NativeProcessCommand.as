package org.npcommand.command
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import org.npcommand.interfaces.INativeProcessCommand;
	import org.osflash.signals.Signal;

	
	/**
	 * A Native command is used to perform an action on a native process application. 
	 * 
	 * <p>A native command contain all information regarding the action to perform:
	 * 	<ul>
	 * 		<li>commandName: the command line argument to perform</li>
	 * 		<li>args: the other arguments</li>
	 * 		<li>workingDirectory: the directory where the application has to be execute</li>
	 * 	</ul>
	 * </p>
	 * <p>
	 * You can listening for different event regarding the command:
	 * 	<ul>
	 * 		<li>output: the standard output of the application</li>
	 * 		<li>error: the standard error output of the application</li>
	 * 		<li>exit: occured when the application exit</li>
	 * 	</ul>
	 * </p>
	 */ 
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
		
		/** @inheritDoc */ 
		public function get workingDirectory():File
		{
			return _workingDirectory;
		}

		public function set workingDirectory(value:File):void
		{
			_workingDirectory = value;
		}
		
		/** @inheritDoc */ 
		public function get args():ArrayCollection
		{
			return _args;
		}

		public function set args(value:ArrayCollection):void
		{
			_args = value;
		}

		/** @inheritDoc */ 
		public function get commandName():String
		{
			return _commandName;
		}

		public function set commandName(value:String):void
		{
			_commandName = value;
		}

		/** @inheritDoc */ 
		public function get exit():Signal
		{
			return _exit;
		}
		
		/** @inheritDoc */ 
		public function get error():Signal
		{
			return _error;
		}
		
		/** @inheritDoc */ 
		public function get output():Signal
		{
			return _output;
		}

		/** @inheritDoc */ 
		public function getByteArray():ByteArray{
			var ba:ByteArray = new ByteArray();
			for each(var arg:* in args)
			{
				if(arg is String){
					ba.writeUTFBytes(arg);	
				}else{
					ba.writeByte(arg);
				}
			}
			return ba;
		}
		
		/** @inheritDoc */ 
		public function getArgs():Vector.<String>{
			var rargs:Vector.<String> = new Vector.<String>;
			if(_commandName != null){
				rargs.push(_commandName);
			}
			for each(var opt:Object in args)
			{
				rargs.push(opt);
			}
			return rargs;
		}
		
	}
}