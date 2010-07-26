package org.npcommand.interfaces
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;

	public interface INativeProcessCommand
	{
		function get workingDirectory():File;
		function set workingDirectory(value:File):void;
		function get args():ArrayCollection;
		function set args(value:ArrayCollection):void;
		function get commandName():String;
		function set commandName(value:String):void;
			
		
		function get exit():Signal;
		function get error():Signal;
		function get output():Signal;
		
		function getArgs():Vector.<String>;
	}
}