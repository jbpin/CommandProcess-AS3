package org.npcommand
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import org.npcommand.command.NativeProcessCommand;
	import org.npcommand.error.NativeProcessNotSupportedError;
	import org.npcommand.interfaces.INativeProcessCommand;
	import org.npcommand.interfaces.INativeProcessService;
	import org.osflash.signals.Signal;
	
	
	[Event(name=IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,type="flash.event.IOErrorEvent")];
	public class NativeProcessService extends EventDispatcher implements INativeProcessService
	{
		private static const DEFAULT_MAC_APP_PATH:String = "/usr/local/bin";
		private static const DEFAULT_WIN_APP_PATH:String = "c:/programs/";
		
		private var _isMacOs:Boolean = false;
		private var _isWindows:Boolean = false;
		
		private var _np:NativeProcess;
		private var _startUpInfo:NativeProcessStartupInfo;
		private var _outBuffer:ByteArray;
		private var _errBuffer:ByteArray;
		
		private var _appPath:File;
		
		private var _currentCmd:INativeProcessCommand;
		
		public function NativeProcessService()
		{
			if(!NativeProcess.isSupported)
			{
				throw new NativeProcessNotSupportedError();
			}
			if(Capabilities.os.toLowerCase().indexOf("mac") != -1){
				_isMacOs = true;
			}else if(Capabilities.os.toLowerCase().indexOf("win") != -1){
				_isWindows = true;
			}
		}
		
		public function get isWindows():Boolean
		{
			return _isWindows;
		}

		public function get isMacOs():Boolean
		{
			return _isMacOs;
		}

		public function initialize(appName:String,path:String=null):void
		{
			try{
				if(path == null){
					_appPath = _isMacOs ? new File(DEFAULT_MAC_APP_PATH) : new File(DEFAULT_WIN_APP_PATH);
				}else{
					_appPath = new File(path);	
				}
			}catch(e:ArgumentError){
				throw new Error("The application path is unreachable. Please verify it, and ensure the application is installed. \npath: "+path);
			}
			try{
				_startUpInfo = new NativeProcessStartupInfo();
				_startUpInfo.executable = _appPath.resolvePath(appName);
			}catch(e:ArgumentError){
				throw new Error("The application seems to be not present in "+path+". Please insure the application name is correct\nappName: "+appName);	
			}
			_np = new NativeProcess();
		}
		
		public function executeCommand(cmd:INativeProcessCommand):void{
			if(_startUpInfo == null){
				throw new Error("The native process is not initialized.");
			}
			if(_np.running){
				//throw new Error("Impossible to execute command, the process is already running");
				injectCommand(cmd);
			}
			_currentCmd = cmd;
			_outBuffer = new ByteArray();
			_errBuffer = new ByteArray();
			_startUpInfo.arguments = cmd.getArgs();
			if(cmd.workingDirectory != null && cmd.workingDirectory.isDirectory){
				_startUpInfo.workingDirectory = cmd.workingDirectory;
			}
			_np.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onOutputData );
			_np.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onErrorData);
			_np.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			
			_np.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onOutputIOError);
			_np.start(_startUpInfo);
		}
		
		private function injectCommand(cmd:INativeProcessCommand):void{
			if(_startUpInfo == null){
				throw new Error("The native process is not initialized.");
			}
			if(!_np.running){
				throw new Error("Impossible to execute command, the process is not running");
			}
			_np.standardInput.writeUTF(cmd.getArgs().toString());
		}
		
		protected function onOutputIOError(e:IOErrorEvent):void{
			dispatchEvent(e);
		}
		
		protected function onOutputData(e:ProgressEvent):void{
			var btemp:ByteArray = new ByteArray();
			_np.standardOutput.readBytes(btemp,0);
			_outBuffer.writeBytes(btemp,0);
			_currentCmd.output.dispatch(btemp);
		}
		
		protected function onErrorData(e:ProgressEvent):void{
			var btemp:ByteArray = new ByteArray();
			_np.standardError.readBytes(btemp,0);
			_errBuffer.writeBytes(btemp,0);
			_currentCmd.error.dispatch(btemp);
		}
		
		protected function onExit(e:NativeProcessExitEvent):void{
			_currentCmd.exit.dispatch({outputData:_outBuffer,errorData:_errBuffer});
		}
		
		public function exit():void{
			if(_np.running){
				_np.exit(false);
			}
		}
		
		public function abord():void{
			if(_np.running){
				_np.exit(true);
			}
		}
	}
}