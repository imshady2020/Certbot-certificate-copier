use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

(*
	Some useful references
	• https://developer.apple.com/library/content/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_about_handlers.html
	• https://stackoverflow.com/questions/33035959/optional-parameters-in-applescript-handlers
	• https://discussions.apple.com/docs/DOC-6681
	• https://certbot.eff.org/docs/

	Files we're looking for, if site name is example.com
	• /etc/letsencrypt/live/example.com/cert.pem
	• /etc/letsencrypt/live/example.com/privkey.pem
*)

property certFolderBase : "/etc/letsencrypt/live/"
property fileNameCertificate : "cert.pem"
property fileNamePrivateKey : "privkey.pem"

property msgPleaseCheck : return & return & "Check the validity of the site’s sub-folder under “" & certFolderBase & "”."
property msgNoSitesFound : "No eligible sites were found." & msgPleaseCheck

property msgGotCertificate0 : "The security certificate for site “"
property msgGotCertificate1 : "” is now on the clipboard." & return & return & ¬
	"After you have dealt with that, press “Continue” to copy the private key to the clipboard."

property msgMissingCertificate : "The certificate file could not be found." & msgPleaseCheck
property msgCertificateFormatFailed : "The certificate file is not in the proper format."

property msgGotPrivateKey : "The site’s private key is now on the clipboard."
property msgMissingPrivateKey : "The private key file could not be found." & msgPleaseCheck
property msgPrivateKeyFormatFailed : "The private key file is not in the proper format."


on run
	set bCancelled to false

	set siteFolders to getSiteFolders()
	if siteFolders is not false then
		if (length of siteFolders is 0) then
			tell me to quitMessage:msgNoSitesFound
			set bCancelled to true
		else if (length of siteFolders is 1) then
			set site to item 1 of siteFolders
		else
			choose from list siteFolders with prompt "Choose the site"
			if the result is not false then
				set site to item 1 of the result
			else
				set bCancelled to true
			end if
		end if

		if not bCancelled then
			set certFolder to certFolderBase & site & "/"

			-- try to get the site certificate
			set fileContents to getFileContents for certFolder & fileNameCertificate

			if fileContents is false then
				tell me to quitMessage:msgMissingCertificate
			else if the length of fileContents is 0 or the first paragraph of fileContents does not contain "BEGIN CERTIFICATE" then
				tell me to quitMessage:msgCertificateFormatFailed
			else
				set the clipboard to fileContents
				display dialog msgGotCertificate0 & site & msgGotCertificate1 with icon note buttons {"Cancel", "Continue"} default button "Continue"

				-- now do the Private Key
				set fileContents to getFileContents for certFolder & fileNamePrivateKey

				if fileContents is false then
					tell me to quitMessage:msgMissingPrivateKey
				else if the length of fileContents is 0 or the first paragraph of fileContents does not contain "BEGIN PRIVATE KEY" then
					tell me to quitMessage:msgPrivateKeyFormatFailed
				else
					set the clipboard to fileContents
					display dialog msgGotPrivateKey with icon note buttons {"Clear Clipboard and Quit", "Quit"} default button "Quit"
					if button returned of the result is not "Quit" then
						set the clipboard to ""
					end if
				end if
			end if
		end if
	end if
end run


on oneButtonMessage:msg button:btn
	display dialog msg with icon note buttons btn default button 1
end oneButtonMessage:button:


on quitMessage:msg
	tell me to oneButtonMessage:msg button:"Quit"
end quitMessage:


(* @return - false if they cancelled the authentication dialogue, else a list of zero or more site (folder) names
*)
to getSiteFolders()
	set rtn to false
	set dirListing to sudoCommand for "ls " & certFolderBase
	log {"•dirListing•", dirListing}

	if dirListing is not false then
		set rtn to every paragraph of dirListing -- convert to a list
	end if

	return rtn
end getSiteFolders


to getFileContents for filePath
	return sudoCommand for "cat " & filePath
end getFileContents


(* @return - false if there was an error (not the shell’s error code), otherwise the output of the command as provided by do shell script
*)
to sudoCommand for theCommand
	set shellResult to false
	try
		with timeout of 5 seconds
			set shellResult to do shell script theCommand ¬
				with prompt "An administrator password is required to access the Certbot site certificate(s)." with administrator privileges
		end timeout
	on error errMsg number errNumber
		if errNumber is not -128 then -- userCanceledErr
			display dialog "A unexpected error has occurred. (" & errNumber & ")" & return & return & errMsg buttons {"Okay"} default button "Okay"
		end if
	end try

	return shellResult
end sudoCommand
