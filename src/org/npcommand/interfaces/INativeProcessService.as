package org.npcommand.interfaces
{
	import flash.desktop.NativeProcess;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.natives.NativeSignal;

	public interface INativeProcessService
	{
		/**
		 * Initialize the process 
		 * 
		 * @param appName the name of the process with the extension if it's needed (e.g Windows app.exe or Mac app)
		 * @param path the path to the application
		 * 
		 * @throw ArgumentError If the application cannot be reached. 
		 * 
		 */ 
		function initialize(appName:String,path:String=null):void;
		
		/**
		 * Start the process - This function can be used to start a listening application without args.
		 *  
		 * @throw Error if the application is already started or if the service is not initalized.
		 *
		 * @see initialize
		 * @see executeCommand
		 */
		function start():void;
		
		/**
		 * Execute a NativeProcessCommand
		 * This method should be used to run a command in the case of command line application who take arguments or to start
		 * a listening process with arguments (e.g StartAppCommand)
		 * 
		 * @param cmd The Command to execute
		 * 
		 * @throw Error if the service is not initialized
		 */ 
		function runCommand(cmd:INativeProcessCommand):void;
		
		/**
		 * Inject command allow you to inject a command in a running process
		 * 
		 * @param cmd the command to execute
		 * 
		 * @throw Error if the 	process is not initialized or application is not running
		 */
		function injectCommand(cmd:INativeProcessCommand):void;
		
		/**
		 * Terminate a running application
		 */
		function exit():void;
		
		/**
		 * Force an application to quit
		 */
		function abort():void;
		
		//Getter and setter
		/**
		 * Dispatch in case of IOOutputError 
		 */ 
		function get IOOutputError():NativeSignal;
		
		/**
		 * Dispatch in case of IOinputError 
		 */
		function get IOInputError():NativeSignal;
		
		/**
		 * return true if the application is running on windows os 
		 */
		function get isWindows():Boolean;
		
		/**
		 * return true if the application is running on mac os
		 */ 
		function get isMacOs():Boolean;
		
		/**
		 * return true if the native process is running 
		 */
		function get isRunning():Boolean;
		
		/**
		 * return the currante initialized native process
		 */ 
		function get nativeProcess():NativeProcess;
	}
}