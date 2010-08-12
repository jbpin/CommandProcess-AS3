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
	import org.osflash.signals.natives.NativeSignal;
	
	/**
	 * The Native process service allow you to use NativeProcess API like a service. 
	 * <p>This library can dialog with two kind of process, the process who take args at execution, and process listening for command.
	 * i.g 	Git process use arg : git init
	 * 		Mysql is a prompt application who take paramters for initialization</p>
	 * 
	 * <p>NativeProcessService contains logic for initializing the startup information and dialog with the process.</p> 
	 */ 
	public class NativeProcessService extends EventDispatcher implements INativeProcessService
	{
		/**
		 *Default MAC application path 
		 */
		private static const DEFAULT_MAC_APP_PATH:String = "/appliations";
		
		/**
		 *Default MAC application path 
		 */
		private static const DEFAULT_WIN_APP_PATH:String = "c:/programs files/";
		
		
		private var _isMacOs:Boolean = false;
		private var _isWindows:Boolean = false;
		
		protected var _np:NativeProcess;
		private var _startUpInfo:NativeProcessStartupInfo;
		private var _outBuffer:ByteArray;
		private var _errBuffer:ByteArray;
		
		private var _appPath:File; //the path to the application
		
		protected var _currentCmd:INativeProcessCommand;
		protected var _injectedCmd:INativeProcessCommand;
		
		private var _IOInputError:NativeSignal; //Native signal for IOError
		private var _IOOutputError:NativeSignal; //Native signal for IOError
		
		/**
		 * Create a Native process service object
		 * 
		 * @throw NativeProcessNotSupportedError An error if native process api is not supported by the application
		 */ 
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
		
		/** @inheritDoc */ 
		public function get IOOutputError():NativeSignal
		{
			return _IOOutputError;
		}
		
		/** @inheritDoc */
		public function get IOInputError():NativeSignal
		{
			return _IOInputError;
		}
		
		/** @inheritDoc */
		public function get isWindows():Boolean
		{
			return _isWindows;
		}
		
		/** @inheritDoc */
		public function get isMacOs():Boolean
		{
			return _isMacOs;
		}
		
		/** @inheritDoc */
		public function get isRunning():Boolean{
			return _np.running;
		}
		
		/** @inheritDoc */
		public function get nativeProcess():NativeProcess{
			return _np;
		}
		
		/** @inheritDoc */
		public function initialize(appName:String,path:String=null):void
		{
			try{
				if(path == null){
					_appPath = _isMacOs ? new File(DEFAULT_MAC_APP_PATH) : new File(DEFAULT_WIN_APP_PATH);
				}else{
					_appPath = new File(path);	
				}
			}catch(e:ArgumentError){
				throw new ArgumentError("The application path is unreachable. Please verify it, and ensure the application is installed. \npath: "+path);
			}
			try{
				_startUpInfo = new NativeProcessStartupInfo();
				_startUpInfo.executable = _appPath.resolvePath(appName);
			}catch(e:ArgumentError){
				throw new ArgumentError("The application seems to be not present in "+path+". Please insure the application name is correct\nappName: "+appName);	
			}
			_np = new NativeProcess();
			_IOInputError = new NativeSignal(_np,IOErrorEvent.STANDARD_INPUT_IO_ERROR);
			_IOOutputError = new NativeSignal(_np,IOErrorEvent.STANDARD_OUTPUT_IO_ERROR);
			_np.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA,onOutputData );
			_np.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onErrorData);
			_np.addEventListener(NativeProcessExitEvent.EXIT, onExit);
		}
		
		/** @inheritDoc */
		public function start():INativeProcessCommand{
			if(_startUpInfo == null){
				throw new Error("The native process is not initialized.");
			}
			if(_np.running){
				throw new Error("Impossible to start the process, is already running");
			}
			_outBuffer = new ByteArray();
			_errBuffer = new ByteArray();
			_currentCmd = new NativeProcessCommand();
			_np.start(_startUpInfo);
			return _currentCmd;
		}
		
		/** @inheritDoc */
		public function runCommand(cmd:INativeProcessCommand):void{
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
			_np.start(_startUpInfo);
		}
		
		/** @inheritDoc */
		public function injectCommand(cmd:INativeProcessCommand):void{
			if(_startUpInfo == null){
				throw new Error("The native process is not initialized.");
			}
			if(!_np.running){
				throw new Error("Impossible to execute command, the process is not running");
			}
			_injectedCmd = cmd;
			_np.standardInput.writeBytes(cmd.getByteArray(),0,cmd.getByteArray().length);
		}
		
		
		protected function onOutputIOError(e:IOErrorEvent):void{
			dispatchEvent(e);
		}
		
		protected function onOutputData(e:ProgressEvent):void{
			var btemp:ByteArray = new ByteArray();
			_np.standardOutput.readBytes(btemp,0);
			_outBuffer.writeBytes(btemp,0);
			if(_injectedCmd != null){
				_injectedCmd.output.dispatch(btemp);
			}
			_currentCmd.output.dispatch(btemp);
		}
		
		protected function onErrorData(e:ProgressEvent):void{
			var btemp:ByteArray = new ByteArray();
			_np.standardError.readBytes(btemp,0);
			_errBuffer.writeBytes(btemp,0);
			if(_injectedCmd != null){
				_injectedCmd.error.dispatch(btemp);
			}
			_currentCmd.error.dispatch(btemp);
		}
		
		protected function onExit(e:NativeProcessExitEvent):void{
			_injectedCmd = null;
			_currentCmd.exit.dispatch({outputData:_outBuffer,errorData:_errBuffer});
		}
		
		/** @inheritDoc */
		public function exit():void{
			if(_np.running){
				_np.exit(false);
			}
		}
		
		/** @inheritDoc */
		public function abort():void{
			if(_np.running){
				_np.exit(true);
			}
		}
	}
}