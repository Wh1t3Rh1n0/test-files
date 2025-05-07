[System.Reflection.Assembly]::LoadWithPartialName("System.Net")
[System.Reflection.Assembly]::LoadWithPartialName("System.Net.Mail") 
[System.Reflection.Assembly]::LoadWithPartialName("System.Net.Mail.MailMessage")


function Set-Credential {
    param (
        [Parameter(Mandatory = $true)] [string]$user_id,
        [Parameter(Mandatory = $true)] [string]$password
    )

    ( New-Object System.Management.Automation.PSCredential(
        $user_id,
        (ConvertTo-SecureString $password -AsPlainText -Force))
    )
}


function Send-MyMailMessage {
    param (
        [Parameter(Mandatory = $true)] [string]$From,
        [Parameter(Mandatory = $true)] [string[]]$To,
        [string[]]$Cc,
        [string[]]$Bcc,
        [Parameter(Mandatory = $true)] [string]$Subject,
        [Parameter(Mandatory = $true)] [string]$Body,
        [Parameter(Mandatory = $true)] [string]$SmtpServer,
        [int]$Port = 587,
        [Parameter(Mandatory = $true)] [pscredential]$Credential,
        [switch]$UseSsl,
        [string[]]$Attachments,
        [switch]$BodyAsHtml
    )

    #Add-Type -AssemblyName System.Net.Mail
    #Add-Type -AssemblyName System.Net

    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = New-Object System.Net.Mail.MailAddress($From)

    # Add recipients
    foreach ($recipient in $To)  { if ($recipient) { $mail.To.Add($recipient) } }
    foreach ($recipient in $Cc)  { if ($recipient) { $mail.CC.Add($recipient) } }
    foreach ($recipient in $Bcc) { if ($recipient) { $mail.Bcc.Add($recipient) } }

    $mail.Subject = $Subject
    $mail.Body = $Body
    $mail.IsBodyHtml = $BodyAsHtml.IsPresent

    # Add attachments
    if ($Attachments) {
        foreach ($path in $Attachments) {
            if (Test-Path $path) {
                $attachment = New-Object System.Net.Mail.Attachment($path)
                $mail.Attachments.Add($attachment)
            } else {
                Write-Error "Attachment not found: $path"
                return
            }
        }
    }

    $smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $Port)
    $smtp.Credentials = New-Object System.Net.NetworkCredential(
        $Credential.UserName,
        $Credential.GetNetworkCredential().Password
    )
    $smtp.EnableSsl = $UseSsl.IsPresent

    try {
        $smtp.Send($mail)
    } catch {
        Write-Error "Failed to send email: $_"
    } finally {
        $mail.Dispose()
    }
}



function Send-Messages {
    param (
        [string]$type,
        [string]$folder
    )

    if ( $user_id -and $user_id -ne "" -and $password -and $password -ne "" ) {
        # Convert $user_id and $password to credential, required by PowerShell.
        $my_credential = ( Set-Credential $user_id $password )
    }

    get-childitem $folder | foreach {
    
        # Email paramaters that never change go here.
        $MailParams = @{
            From = $from
            To = $to
            SmtpServer = $smtp_server
            Port = $port
        }

        if ( $user_id -and $user_id -ne "" -and $password -and $password -ne "" ) {
            $MailParams.Credential = $my_credential
        }

        if ($useSsl) {
            $MailParams.UseSsl = $true
        }
        

        # Counter, to track which email we're on.
        $global:email_counter += 1

        # Subject is always: "$subject $email_counter: {test file name}"
        # Examples:          "BHIS TEST 1: REG_File.reg"
        #                    "BHIS TEST 2: QR_Code-Harmless_Table.html"
        $MailParams.Subject = ( $subject + " " + $global:email_counter + ": " + $_.Name )


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
            $MailParams.Body = ( $body + "`nTest email #" + $global:email_counter + "`nAttachment: " + $_.Name + "`nSent at: $(date)" )
        }


        $output = ( ( get-date -Format "yyyy-MM-dd HH:mm K> " ) + "SENDING: '" + $MailParams.Subject + "'..." ) 
        echo $output
        if ( $log_file ) { echo $output | add-content $log_file }
    
        if ( $method -eq 1 ) { 
            Send-MailMessage @MailParams
        } elseif ($method -eq 2) { 
            Send-MyMailMessage @MailParams 
        } else {
            echo "ERROR: Method must be set to 1 or 2. Quitting."
            exit
        }

        echo "...Sleeping $sleep_interval seconds..."
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
        [string]$sleep_interval = 60,

        [string]$log_file = "./EmailTest.log",

        [string]$method = 2
    )

    $global:email_counter = 0
    
    echo ""
    Send-Messages -type "message" -folder $messages_folder
    Send-Messages -type "attachment" -folder $attachments_folder
    

    echo "ALL DONE!"
}




