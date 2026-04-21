$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8765
$prefix = "http://localhost:$port/"

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm'  = 'text/html; charset=utf-8'
    '.txt'  = 'text/plain; charset=utf-8'
    '.md'   = 'text/plain; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.json' = 'application/json; charset=utf-8'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.gif'  = 'image/gif'
    '.webp' = 'image/webp'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
    $listener.Start()
} catch {
    Write-Host "Failed to bind $prefix. Another server may be using port $port." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$openUrl = "${prefix}news_preview.html"
Write-Host "Serving $root" -ForegroundColor Green
Write-Host "Opening $openUrl" -ForegroundColor Green
Write-Host "Press Ctrl+C in this window to stop the server."
Start-Process $openUrl | Out-Null

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response

        $relPath = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath.TrimStart('/'))
        if ([string]::IsNullOrEmpty($relPath)) { $relPath = 'news_preview.html' }

        $fullPath = Join-Path $root $relPath
        $resolved = $null
        try { $resolved = (Resolve-Path -LiteralPath $fullPath -ErrorAction Stop).Path } catch {}

        if (-not $resolved -or -not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            $res.StatusCode = 404
            $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $relPath")
            $res.ContentType = 'text/plain; charset=utf-8'
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
            $res.Close()
            continue
        }

        $ext = [System.IO.Path]::GetExtension($resolved).ToLowerInvariant()
        $contentType = $mime[$ext]
        if (-not $contentType) { $contentType = 'application/octet-stream' }

        try {
            $bytes = [System.IO.File]::ReadAllBytes($resolved)
            $res.StatusCode = 200
            $res.ContentType = $contentType
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } catch {
            $res.StatusCode = 500
            $msg = [System.Text.Encoding]::UTF8.GetBytes("500: $($_.Exception.Message)")
            $res.OutputStream.Write($msg, 0, $msg.Length)
        } finally {
            $res.Close()
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
