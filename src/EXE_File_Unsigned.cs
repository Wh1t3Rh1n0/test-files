// How to compile with csc.exe:
// c:\windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /unsafe EXE_File_Unsigned.cs

using System.Windows.Forms; // Used to create a message box.
// using System.Diagnostics;   // Used to launch processes.

class ProcessStart {
    static void Main(string[] args) {
        // Execute "cmd.exe /k notepad.exe".
        /* Process notePad = new Process();
        notePad.StartInfo.FileName = "cmd.exe";
        notePad.StartInfo.Arguments = "/k notepad.exe";
        notePad.Start(); */
        
        // Show a simple message box.
        MessageBox.Show("EXE file executed successfully.");
    }
}