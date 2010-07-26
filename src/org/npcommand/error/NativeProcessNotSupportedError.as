package org.npcommand.error
{
	public class NativeProcessNotSupportedError extends Error
	{
		public function NativeProcessNotSupportedError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}