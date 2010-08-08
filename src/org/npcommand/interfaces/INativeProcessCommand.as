package org.npcommand.interfaces
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import org.osflash.signals.Signal;

	public interface INativeProcessCommand
	{
		/**
		 * Get or set the working directory for an initialized or command line command
		 */
		function get workingDirectory():File;
		
		function set workingDirectory(value:File):void;
		
		/**
		 * Get or Set the arguments for the command
		 */ 
		function get args():ArrayCollection;
		function set args(value:ArrayCollection):void;
		
		/**
		 * Get or Set the command name to perform
		 */ 
		function get commandName():String;
		function set commandName(value:String):void;
			
		/**
		 * Signal for application exit
		 * 
		 * @return object data with ouputData and errorData occured during the life of the application command
		 */ 
		function get exit():Signal;
		
		/**
		 * Signal for standard error
		 * 
		 * @return object data type ByteArray contains error data
		 */ 
		function get error():Signal;
		
		/**
		 * Signal for standard output
		 * 
		 * @return object data type ByteArray contains output data
		 */ 
		function get output():Signal;
		
		/**
		 * Transform the commandName and the args ArrayCollection to a vector of string used to initialized the native process
		 * 
		 * @return Vector the vector of string
		 */ 
		function getArgs():Vector.<String>;
		
		/**
		 * Convert command name and arguments into ByteArray used to inject command
		 * 
		 * @return ByteArray
		 */ 
		function getByteArray():ByteArray;
	}
}