function Invoke-DirectSendSpoofingTest {
    param (
        [Parameter(Mandatory = $true)] [string]$smart_host,

        [Parameter(Mandatory = $true)] [string]$to,

        [Parameter(Mandatory = $true)] [string]$from_valid_mailbox,
        [Parameter(Mandatory = $true)] [string]$from_invalid_mailbox,
        [Parameter(Mandatory = $true)] [string]$from_external_domain,

        [string]$body = "This is a test. Please notify the tester if you receive this message.",

        [string]$sleep_interval = 5
    )

    $subject = "DS Test 1: Sent from valid mailbox"
    echo "Sending: '$subject'..."
    Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_valid_mailbox -To $to

    start-sleep $sleep_interval

    $subject = "DS Test 2: Sent from non-existent mailbox"
    echo "Sending: '$subject'..."
    Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_invalid_mailbox -To $to

    start-sleep $sleep_interval

    $subject = "DS Test 3: Sent from external domain"
    echo "Sending: '$subject'..."
    Send-MailMessage -SmtpServer $smart_host -Subject $subject -Body $body -BodyAsHtml -From $from_external_domain -To $to
    
    echo "All done!"
}