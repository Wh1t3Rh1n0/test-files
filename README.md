Test Files
==========

*Test files of multiple types that can be used to deliver executable payloads.*


Description
-----------

This is a collection of files that I created for testing in a variety of scenarios, including:

- Delivery as email attachments.
- Upload to web applications.
- Application allow-listing enforcement.
- Effects of Mark of the Web on various files.
- General suitability for use as an executable payload for social engineering attacks.

**All the files in this collection contain either benign, executable code or no executable code at all.**

- The EXE file used in almost all cases is BGInfo.exe from the SysInternals toolset.
- The other, unsigned EXE file included in this collection is a very simple example that only opens a message box to confirm execution.
	- Source code is included for this file.
- All other executable files either display a message to confirm execution or run another benign process like `calc.exe`.

A helper script, `Add MOTW to all.bat`, is also included, which will apply the Mark of the Web to all the files in the folder where it is executed.