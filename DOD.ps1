# how many days old you would like the downloads to be for removal (must be negative)
$daysOld = -90

# optional email inputs, see commented examples (make sure to uncomment the function call below as well)
$sendingEmail = "" # sender@gmail.com
$senderPw = "" # SenderPassword123
$receivingEmail = "" # recipient@gmail.com
$smtpServer = "" # smtp.gmail.com
$port = 0 # 587

function GetTargetDownloads() {
    $user = $env:USERNAME
    $downloads = "C:\Users\$user\Downloads"
    Get-ChildItem -Path $downloads |
        Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays($daysOld)}
}

function DeleteTargetDownloads() {
    GetTargetDownloads |
        Remove-Item -Recurse -Force -WhatIf # remove '-WhatIf' parameter when ready to remove files
}

function MailResults() {
    $credentials = New-Object Management.Automation.PSCredential $sendingEmail,
        ($senderPw | ConvertTo-SecureString -AsPlainText -Force)
    $messageParams = @{
    Subject = "Downloads Deleted - DOD"
    Body = GetTargetDownloads |
        Sort-Object -Property LastWriteTime -Descending |
        Select-Object Name,LastWriteTime |
        ConvertTo-Html |
        Out-String
    From = $sendingEmail
    To = $receivingEmail
    SmtpServer = $smtpServer
    Port = $port
    Credential = $credentials
    UseSsl = $True
    BodyAsHtml = $True
    }

    Send-MailMessage @messageParams
}

#MailResults
DeleteTargetDownloads