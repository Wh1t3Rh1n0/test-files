function Set-Credential {
    param (
        [string]$user_id,
        [string]$password
    )

    ( New-Object System.Management.Automation.PSCredential(
        $user_id,
        (ConvertTo-SecureString $password -AsPlainText -Force))
    )
}


function Send-Messages {
    param (
        [string]$type,
        [string]$folder
    )

    # Convert $user_id and $password to credential, required by PowerShell.
    $my_credential = ( Set-Credential $user_id $password )

    get-childitem $folder | foreach {
    
        # Email paramaters that never change go here.
        $MailParams = @{
            From = $from
            To = $to
            SmtpServer = $smtp_server
            Port = $port
            Credential = $my_credential
        }

        if ($useSsl) {
            $MailParams.UseSsl = $true
        }
        

        # Counter, to track which email we're on.
        $email_counter += 1

        # Subject is always: "$subject $email_counter: {test file name}"
        # Examples:          "BHIS TEST 1: REG_File.reg"
        #                    "BHIS TEST 2: QR_Code-Harmless_Table.html"
        $MailParams.Subject = ( $subject + " " + $email_counter + ": " + $_.Name )


        if ( $type -eq "attachment" ) {
            $MailParams.Attachments = ( $($attachments_folder) + $_.Name )
            echo $MailParams.Attachments
        } elseif ( $type -eq "message" ) {
            $body = $_.FullName
        } else {
            echo 'ERROR: $type not understood. Quitting.'
            exit
        }

        # If $body contains a valid file path, send that file as the message body in HTML format.
        # Otherwise send an attachment, and print details in the message body.
        if (Test-Path $body -PathType Leaf){
            $MailParams.BodyAsHtml = $true
            $MailParams.Body = ( get-content $body -raw )
        } else {
            $MailParams.Body = ( $body + "`nTest email #" + $email_counter + "`nAttachment: " + $_.Name + "`nSent at: $(date)" )
        }


        echo ( "Sending: '" + $MailParams.Subject + "'..." )
    
        #Send-MailMessage @MailParams

        start-sleep $sleep_interval
    }

}


function Invoke-EmailTest {
    param (
        [string]$user_id,
        [string]$password,
        [Parameter(Mandatory = $true)] [string]$from,
        [Parameter(Mandatory = $true)] [string]$to,
        [Parameter(Mandatory = $true)] [string]$subject,
        [Parameter(Mandatory = $true)] [string]$body,

        [string]$smtp_server = "smtp.mail.yahoo.com",
        [string]$port = 587,
        [string]$useSsl = $true,

        [string]$attachments_folder = "$PWD\Attachments\",
        [string]$messages_folder = "$PWD\Messages\",
        [string]$sleep_interval = 5
    )

    $email_counter = 0

    Send-Messages -type "attachment" -folder $attachments_folder
    Send-Messages -type "message" -folder $messages_folder

    echo "ALL DONE!"
}




