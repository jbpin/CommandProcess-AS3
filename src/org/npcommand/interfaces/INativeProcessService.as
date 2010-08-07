package org.npcommand.interfaces
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public interface INativeProcessService
	{
		function initialize(appName:String,path:String=null):void;
		function executeCommand(cmd:INativeProcessCommand):void
		
	}
}