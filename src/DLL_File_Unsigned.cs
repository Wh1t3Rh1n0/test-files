/* 
How to build the DLL:
=====================

1. Compile to DLL with: 

C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /target:library /reference:System.Windows.Forms.dll /unsafe /out:DLL_File_Unsigned.dll DLL_File_Unsigned.cs 


2. Install Windows SDK to get ildasm.exe: 

https://learn.microsoft.com/en-us/windows/apps/windows-sdk/downloads


3. Disassemble from DLL to IL:

"c:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8.1 Tools\x64\ildasm.exe" DLL_File_Unsigned.dll /out:DLL_File_Unsigned.il


4. Edit the IL file in notepad. Add ".export [1]" as the very first line in these TWO methods:


.method public hidebysig static int32 DllRegisterServer() cil managed
{
    .export [1]          // <-- ADD THIS LINE

    .maxstack  8
    ...
}

.method public hidebysig static int32 DllUnregisterServer() cil managed
{
    .export [2]          // <-- ADD THIS LINE (different ordinal)

    .maxstack  8
    ...
}


5. Save the file and reassemble back to DLL:

C:\Windows\Microsoft.NET\Framework\v4.0.30319\ilasm.exe DLL_File_Unsigned.il /DLL /output=DLL_File_Unsigned.dll


6. Execute the DLL. The entry point name must match the method name in your source code, but you can change the source code to make it whatever you like:

rundll32.exe DLL_File_Unsigned.dll,DllRegisterServer

OR

rundll32.exe DLL_File_Unsigned.dll,DllUnregisterServer

OR

regsvr32.exe /s /i DLL_File_Unsigned.dll

OR

regsvr32.exe /s /u DLL_File_Unsigned.dll

*/


//using System.Diagnostics;      // Used to launch processes.
using System.Windows.Forms;    // Used to create the MessageBox

class TestDLL {
    public static int DllRegisterServer() {
        // Execute "cmd.exe /k notepad.exe".
        /* Process notePad = new Process();
        notePad.StartInfo.FileName = "cmd.exe";
        notePad.StartInfo.Arguments = "/k notepad.exe";
        notePad.Start(); */
    
        MessageBox.Show("DLL executed successfully via DllRegisterServer!", "DLL Execution Test");
        return 0;   // S_OK = success
    }

    public static int DllUnregisterServer() {
        MessageBox.Show("DLL executed successfully via DllUnegisterServer!", "DLL Execution Test");
        return 0;   // S_OK
    }

}