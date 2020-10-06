#!/bin/bash
# ------------------------------------------------------------------
# [Author] Original script for MagpiDownloader from @rubemlrm - https://github.com/joergi/MagPiDownloader
#          adapted by @joergi for Wireframe Downloader: https://github.com/joergi/WireframeDownloader
#          they are downloadable for free under https://wireframe.raspberrypi.org/issues
#          or you can buy the paper issues under: https://store.rpipress.cc/collections/wireframe
#          this script is under GNU GENERAL PUBLIC LICENSE 3
# ------------------------------------------------------------------

# VERSION=0.1.2
# USAGE="Usage: sh wireframe-downloader.sh [-f firstissue] [-l lastissue]"


Param(
    [string]$f,
    [string]$l
)

# control variables
$i = 1


$baseDir = ($PSScriptRoot)
$issues = Get-Content "$baseDir\regular-issues.txt" -First 1
$baseUrl = "https://wireframe.raspberrypi.org/issues/"
$web = New-Object system.net.webclient
$errorCount = 0

# Check if directory dont exist and try create
if ( -Not (Test-Path -Path "$baseDir\issues" ) ) {
    New-Item -ItemType directory -Path "$baseDir\issues"
}


if ($f) {
    $i = [int]$f
}

if ($l) {
    $issues = [int]$l
}

do {
    #start scrapping directory and download files

    $tempCounter = if ($i -le 9) { "{0:00}" -f $i }  Else { $i }

    $fileReponse = ((Invoke-WebRequest -UseBasicParsing "$baseUrl$tempCounter/pdf").Links | Where-Object { $_.href -like "http*" } | Where-Object class -eq c-link)
    if ($fileReponse) {
        try {
            $web.DownloadFile($fileReponse.href, "$baseDir\issues\" + $fileReponse.download)
            Write-Verbose -Message "Downloaded from  $fileReponse.href"
        }
        Catch {
            Write-Verbose -Message $_.Exception | format-list -force
            Write-Verbose -Message "Ocorred an error trying download $fileReponse.download"
            $errorCount++
        }
    }
    $i++
} While ($i -le $issues)

if ($errorCount -gt 0) {
    exit 1
}
