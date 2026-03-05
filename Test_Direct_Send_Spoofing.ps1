function Invoke-DirectSendSpoofingTest {
    param (
        [Parameter(Mandatory = $true)] [string]$smart_host,

        [Parameter(Mandatory = $true)] [string]$to,

        [Parameter(Mandatory = $true)] [string]$from_valid_mailbox,
        [Parameter(Mandatory = $true)] [string]$from_invalid_mailbox,
        [Parameter(Mandatory = $true)] [string]$from_external_domain,
        [Parameter(Mandatory = $true)] [string]$from_unregistered_domain,

        [string]$body = "This is a test. Please notify the tester if you receive this message.",

        [string]$sleep_interval = 5
    )
    $subject_number = 1

    $subject = "DS Test ${subject_number}: Sent from valid mailbox"
    echo "Sending: '$subject'..."
    Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_valid_mailbox -To $to

    start-sleep $sleep_interval

    $subject_number = $subject_number + 1
    $subject = "DS Test ${subject_number}: Sent from non-existent mailbox"
    echo "Sending: '$subject'..."
    Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_invalid_mailbox -To $to

    start-sleep $sleep_interval

    if ($from_external_domain.Contains(",")) {
        $external_address_array = $from_external_domain -split ","
        foreach ($external_address in $external_address_array) {
            $subject_number = $subject_number + 1
            $subject = "DS Test ${subject_number}: Sent from external domain"
            echo "Sending: '$subject'..."
            Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $external_address -To $to
            start-sleep $sleep_interval
        }
    } else {   
        $subject_number = $subject_number + 1
        $subject = "DS Test ${subject_number}: Sent from external domain"
        echo "Sending: '$subject'..."
        Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_external_domain -To $to
        start-sleep $sleep_interval
    }


    $subject_number = $subject_number + 1
    $subject = "DS Test ${subject_number}: Sent from unregistered domain"
    echo "Sending: '$subject'..."
    Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_unregistered_domain -To $to

    echo "All done!"
}