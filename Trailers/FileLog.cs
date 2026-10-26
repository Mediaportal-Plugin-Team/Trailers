using MediaPortal.Configuration;
using System;
using System.IO;
using System.Threading;
using Trailers.Providers;
using Trailers.Providers.TMDb.API;

namespace Trailers
{
    static class FileLog
    {
        private static readonly string mLogFilename = Config.GetFile(Config.Dir.Log,"Trailers.log");
        private static readonly string mBackupFilename = Config.GetFile(Config.Dir.Log, "Trailers.bak");
        private static readonly Object mLockObject = new object();

        static FileLog()
        {
            // default logging before we load settings
            PluginSettings.LogLevel = 2;

            if (File.Exists(mLogFilename))
            {
                if (File.Exists(mBackupFilename))
                {
                    try
                    {
                        File.Delete(mBackupFilename);
                    }
                    catch
                    {
                        Error("Failed to remove old backup log");
                    }
                }
                try
                {
                    File.Move(mLogFilename, mBackupFilename);
                }
                catch
                {
                    Error("Failed to move logfile to backup");
                }
            }

            // listen to web events from the TMDb API so we can provide useful logging            
            TMDbAPI.OnDataSend += new TMDbAPI.OnDataSendDelegate(TMDbAPI_OnDataSend);
            TMDbAPI.OnDataReceived += new TMDbAPI.OnDataReceivedDelegate(TMDbAPI_OnDataReceived);
        }

        internal static void Info(String log)
        {
            if (PluginSettings.LogLevel >= 2)
                WriteToFile(String.Format(CreatePrefix(), "INFO", log));
        }

        internal static void Info(String format, params Object[] args)
        {
            Info(String.Format(format, args));
        }

        internal static void Debug(String log)
        {
            if (PluginSettings.LogLevel >= 3)
                WriteToFile(String.Format(CreatePrefix(), "DEBG", log));
        }

        internal static void Debug(String format, params Object[] args)
        {
            Debug(String.Format(format, args));
        }

        internal static void Error(String log)
        {
            if (PluginSettings.LogLevel >= 0)
                WriteToFile(String.Format(CreatePrefix(), "ERR ", log));
        }

        internal static void Error(String format, params Object[] args)
        {
            Error(String.Format(format, args));
        }

        internal static void Warning(String log)
        {
            if (PluginSettings.LogLevel >= 1)
                WriteToFile(String.Format(CreatePrefix(), "WARN", log));
        }

        internal static void Warning(String format, params Object[] args)
        {
            Warning(String.Format(format, args));
        }

        private static String CreatePrefix()
        {
            return DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + " [{0}] " + String.Format("[{0}][{1}]", Thread.CurrentThread.Name, Thread.CurrentThread.ManagedThreadId.ToString().PadLeft(2,'0')) +  ": {1}";
        }

        private static void TMDbAPI_OnDataSend(string address, string data)
        {
            address = address.Replace( TMDbCredentials.ApiKey, "********" );

            if (!string.IsNullOrEmpty(data))
            {
                Debug("Address: {0}, Post: {1}", address, data);
            }
            else
            {
                Debug("Address: {0}", address);
            }
        }

        private static void TMDbAPI_OnDataReceived(string response)
        {
            Debug("Response: {0}", response ?? "null");
        }

        private static void WriteToFile(String log)
        {
            try
            {
                lock (mLockObject)
                {
                    StreamWriter sw = File.AppendText(mLogFilename);
                    sw.WriteLine(log);
                    sw.Close();
                }
            }
            catch
            {
                Error("Failed to write out to log");
            }
        }
    }
}
