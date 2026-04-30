$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$startPort = 8765
$port = $startPort
$prefix = $null
$rawPrefix = 'https://raw.githubusercontent.com/erthu-games/advr-news/refs/heads/master/news/'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$targetThumbnailRatio = [double](16.0 / 9.0)
# Path to the Python helper that owns image optimization, GIF -> MP4 conversion,
# thumbnail generation and the news.txt insert. The /api/create-post endpoint
# shells out to this script so the optimization rules stay in one place.
# The path can be overridden with the ADVR_CREATE_NEWS_POST env var.
$createNewsPostScript = if ($env:ADVR_CREATE_NEWS_POST) {
    $env:ADVR_CREATE_NEWS_POST
} else {
    Join-Path $root '..\..\..\Ancient_Dungeon\Rogue3DVr\Tools\create_news_post.py'
}

Add-Type -AssemblyName System.Drawing

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

function Send-Bytes($res, [int]$statusCode, [string]$contentType, [byte[]]$bytes) {
    try {
        $res.StatusCode = $statusCode
        $res.ContentType = $contentType
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch [System.InvalidOperationException] {
        Write-Host "Response was already closed by the browser." -ForegroundColor DarkYellow
    } catch [System.Net.HttpListenerException] {
        Write-Host "Browser closed the connection before the response finished." -ForegroundColor DarkYellow
    } finally {
        try { $res.Close() } catch {}
    }
}

function Send-Text($res, [int]$statusCode, [string]$contentType, [string]$text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    Send-Bytes $res $statusCode $contentType $bytes
}

function Send-Json($res, [int]$statusCode, $payload) {
    $json = $payload | ConvertTo-Json -Depth 8
    Send-Text $res $statusCode 'application/json; charset=utf-8' $json
}

function Read-JsonBody($req) {
    $reader = New-Object System.IO.StreamReader($req.InputStream, [System.Text.Encoding]::UTF8)
    $text = $reader.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text | ConvertFrom-Json
}

function ConvertTo-NewsRelativePath([string]$path) {
    if ([string]::IsNullOrWhiteSpace($path)) { throw 'Missing news path.' }
    $relative = $path.Trim()
    if ($relative.StartsWith($rawPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $relative.Substring($rawPrefix.Length)
    }
    $relative = $relative.TrimStart('/', '\') -replace '/', [System.IO.Path]::DirectorySeparatorChar
    if ([System.IO.Path]::IsPathRooted($relative) -or $relative -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "Unsafe news path: $path"
    }
    return $relative
}

function Resolve-NewsPath([string]$path, [switch]$PathMustExist) {
    $relative = ConvertTo-NewsRelativePath $path
    $fullPath = Join-Path $root $relative
    if ($PathMustExist) {
        $fullPath = (Resolve-Path -LiteralPath $fullPath -ErrorAction Stop).Path
    } else {
        $parent = Split-Path -Parent $fullPath
        $resolvedParent = (Resolve-Path -LiteralPath $parent -ErrorAction Stop).Path
        $fullPath = Join-Path $resolvedParent (Split-Path -Leaf $fullPath)
    }

    if (-not $fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes news folder: $path"
    }

    return @{ FullPath = $fullPath; RelativePath = ($relative -replace '\\', '/') }
}

function Get-ArticleInfo([string]$path) {
    $resolved = Resolve-NewsPath $path -PathMustExist
    if (-not (Test-Path -LiteralPath $resolved.FullPath -PathType Leaf)) {
        throw "Article file not found: $path"
    }

    $directory = Split-Path -Parent $resolved.FullPath
    $relativeDirectory = [System.IO.Path]::GetDirectoryName($resolved.RelativePath)
    if ($relativeDirectory) { $relativeDirectory = $relativeDirectory -replace '\\', '/' }

    return @{
        ArticlePath = $resolved.FullPath
        Directory = $directory
        RelativePath = $resolved.RelativePath
        RelativeDirectory = $relativeDirectory
    }
}

function Split-NewsBlocks([string]$text) {
    return [regex]::Split($text, '(?m)^---\s*$') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

function Get-NewsBlockFields([string]$block) {
    $fields = @{}
    foreach ($rawLine in ($block -split "`r?`n")) {
        $line = $rawLine.Trim()
        if ($line -match '^(TITLE|DATE|THUMBNAIL|DESCRIPTION|PATH):\s*(.*)$') {
            $fields[$matches[1].ToUpperInvariant()] = $matches[2].Trim()
        }
    }
    return $fields
}

function Get-NewsIndexEntries() {
    $newsPath = Join-Path $root 'news.txt'
    $text = [System.IO.File]::ReadAllText($newsPath, [System.Text.Encoding]::UTF8)
    $entries = New-Object System.Collections.Generic.List[object]

    foreach ($block in (Split-NewsBlocks $text)) {
        $fields = Get-NewsBlockFields $block
        if (-not $fields['TITLE']) { continue }
        $entries.Add(@{
            title = [string]$fields['TITLE']
            date = [string]$fields['DATE']
            description = [string]$fields['DESCRIPTION']
            thumbnail = [string]$fields['THUMBNAIL']
            path = [string]$fields['PATH']
        })
    }

    return $entries
}

function Write-NewsBlocks($blocks, [string]$newline) {
    $newsPath = Join-Path $root 'news.txt'
    $text = (($blocks | ForEach-Object { $_.Trim() }) -join ($newline + '---' + $newline)).Trim() + $newline
    [System.IO.File]::WriteAllText($newsPath, $text, $utf8NoBom)
}

function Get-SafeFileName([string]$fileName) {
    $safeName = [System.IO.Path]::GetFileName($fileName)
    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
        $safeName = $safeName.Replace($char, '_')
    }
    $safeName = ($safeName -replace '\s+', '_').Trim('_')
    if ([string]::IsNullOrWhiteSpace($safeName)) { $safeName = 'thumbnail.jpg' }
    return $safeName
}

function Save-UploadedThumbnail($body, $articleInfo) {
    if ([string]::IsNullOrWhiteSpace($body.thumbnailDataBase64)) { return $null }

    $data = [string]$body.thumbnailDataBase64
    $data = $data -replace '^data:.*?;base64,', ''
    $bytes = [System.Convert]::FromBase64String($data)
    $safeName = Get-SafeFileName ([string]$body.thumbnailFileName)
    $target = Join-Path $articleInfo.Directory $safeName

    if (Test-Path -LiteralPath $target) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($safeName)
        $extension = [System.IO.Path]::GetExtension($safeName)
        $safeName = '{0}_{1}{2}' -f $baseName, (Get-Date -Format 'yyyyMMddHHmmss'), $extension
        $target = Join-Path $articleInfo.Directory $safeName
    }

    [System.IO.File]::WriteAllBytes($target, $bytes)
    $relative = ($articleInfo.RelativeDirectory + '/' + $safeName).TrimStart('/')
    return $rawPrefix + $relative
}

function Update-ArticleHeading([string]$articlePath, [string]$oldTitle, [string]$newTitle, [bool]$force) {
    if ([string]::IsNullOrWhiteSpace($newTitle) -or -not (Test-Path -LiteralPath $articlePath -PathType Leaf)) { return $false }

    $text = [System.IO.File]::ReadAllText($articlePath, [System.Text.Encoding]::UTF8)
    $newline = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines = $text -split "`r?`n", -1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ([string]::IsNullOrWhiteSpace($lines[$i])) { continue }

        if ($lines[$i] -match '^(#+)\s+<color=(#[0-9a-fA-F]{3,8})>(.*?)</color>\s*$') {
            if ($force -or $matches[3].Trim() -eq $oldTitle) {
                $lines[$i] = '{0} <color={1}>{2}</color>' -f $matches[1], $matches[2], $newTitle
                [System.IO.File]::WriteAllText($articlePath, ($lines -join $newline), $utf8NoBom)
                return $true
            }
        } elseif ($lines[$i] -match '^(#+)\s+(.*?)\s*$') {
            if ($force -or $matches[2].Trim() -eq $oldTitle) {
                $lines[$i] = '{0} {1}' -f $matches[1], $newTitle
                [System.IO.File]::WriteAllText($articlePath, ($lines -join $newline), $utf8NoBom)
                return $true
            }
        }

        return $false
    }

    return $false
}

function Save-NewsEntry($body) {
    $newsPath = Join-Path $root 'news.txt'
    $text = [System.IO.File]::ReadAllText($newsPath, [System.Text.Encoding]::UTF8)
    $newline = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $blocks = Split-NewsBlocks $text
    $updatedBlocks = New-Object System.Collections.Generic.List[string]
    $found = $false
    $headingUpdated = $false
    $thumbnailWritten = $false
    $updatedEntry = $null

    foreach ($block in $blocks) {
        $fields = Get-NewsBlockFields $block
        if ($fields['PATH'] -eq $body.originalPath) {
            $found = $true
            $oldTitle = [string]$fields['TITLE']
            $articlePath = [string]$fields['PATH']
            $articleInfo = Get-ArticleInfo $articlePath
            $thumbnail = [string]$body.thumbnail
            $uploadedThumbnail = Save-UploadedThumbnail $body $articleInfo
            if ($uploadedThumbnail) {
                $thumbnail = $uploadedThumbnail
                $thumbnailWritten = $true
            }

            $title = ([string]$body.title).Trim()
            $date = ([string]$body.date).Trim()
            $description = ([string]$body.description).Trim()
            if ([string]::IsNullOrWhiteSpace($title)) { throw 'Title cannot be empty.' }
            if ([string]::IsNullOrWhiteSpace($date)) { throw 'Date cannot be empty.' }

            $lines = New-Object System.Collections.Generic.List[string]
            $lines.Add('TITLE: ' + $title)
            $lines.Add('DATE: ' + $date)
            if (-not [string]::IsNullOrWhiteSpace($thumbnail)) { $lines.Add('THUMBNAIL: ' + $thumbnail.Trim()) }
            if (-not [string]::IsNullOrWhiteSpace($description)) { $lines.Add('DESCRIPTION: ' + $description) }
            $lines.Add('PATH: ' + $articlePath)
            $updatedBlocks.Add($lines -join $newline)

            $headingUpdated = Update-ArticleHeading $articleInfo.ArticlePath $oldTitle $title ([bool]$body.updateArticleHeading)
            $updatedEntry = @{
                title = $title
                date = $date
                thumbnail = $thumbnail
                description = $description
                path = $articlePath
            }
        } else {
            $updatedBlocks.Add($block.Trim())
        }
    }

    if (-not $found) { throw 'Could not find the selected news entry in news.txt.' }
    Write-NewsBlocks $updatedBlocks $newline

    return @{ ok = $true; entry = $updatedEntry; articleHeadingUpdated = $headingUpdated; thumbnailWritten = $thumbnailWritten }
}

function Remove-NewsEntry($body) {
    $newsPath = Join-Path $root 'news.txt'
    $text = [System.IO.File]::ReadAllText($newsPath, [System.Text.Encoding]::UTF8)
    $newline = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $blocks = Split-NewsBlocks $text
    $updatedBlocks = New-Object System.Collections.Generic.List[string]
    $removedPath = $null

    foreach ($block in $blocks) {
        $fields = Get-NewsBlockFields $block
        if ($fields['PATH'] -eq $body.originalPath) {
            $removedPath = [string]$fields['PATH']
        } else {
            $updatedBlocks.Add($block.Trim())
        }
    }

    if (-not $removedPath) { throw 'Could not find the selected news entry in news.txt.' }
    Write-NewsBlocks $updatedBlocks $newline

    $archivePath = $null
    if ([bool]$body.archiveFolder) {
        $articleInfo = Get-ArticleInfo $removedPath
        $articleDirectory = (Resolve-Path -LiteralPath $articleInfo.Directory -ErrorAction Stop).Path
        if ($articleDirectory -eq $root) { throw 'Refusing to archive the news root folder.' }

        $archiveRoot = Join-Path $root '_removed_posts'
        if (-not (Test-Path -LiteralPath $archiveRoot -PathType Container)) {
            New-Item -ItemType Directory -Path $archiveRoot | Out-Null
        }

        $folderName = Split-Path -Leaf $articleDirectory
        $target = Join-Path $archiveRoot ('{0}_{1}' -f $folderName, (Get-Date -Format 'yyyyMMddHHmmss'))
        Move-Item -LiteralPath $articleDirectory -Destination $target
        $archivePath = $target
    }

    return @{ ok = $true; removedPath = $removedPath; archivePath = $archivePath }
}

function Get-ArticleAssets($articlePath) {
    $articleInfo = Get-ArticleInfo $articlePath
    $extensions = @('.jpg', '.jpeg', '.png', '.gif', '.webp')
    $assets = Get-ChildItem -LiteralPath $articleInfo.Directory -File |
        Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() } |
        Sort-Object Name |
        ForEach-Object {
            $relative = ($articleInfo.RelativeDirectory + '/' + $_.Name).TrimStart('/')
            @{ name = $_.Name; url = $rawPrefix + $relative }
        }

    return @{ ok = $true; assets = @($assets) }
}

function Resolve-LocalThumbnailPath([string]$thumbnail) {
    if ([string]::IsNullOrWhiteSpace($thumbnail)) { throw 'This entry has no thumbnail.' }
    if ($thumbnail -match '^https?:' -and -not $thumbnail.StartsWith($rawPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Only thumbnails inside the local news folder can be cropped.'
    }

    $resolved = Resolve-NewsPath $thumbnail -PathMustExist
    if (-not (Test-Path -LiteralPath $resolved.FullPath -PathType Leaf)) {
        throw "Thumbnail file not found: $thumbnail"
    }

    $extension = [System.IO.Path]::GetExtension($resolved.FullPath).ToLowerInvariant()
    if ($extension -notin @('.jpg', '.jpeg', '.png')) {
        throw 'Only .jpg, .jpeg, and .png thumbnails can be cropped.'
    }

    return $resolved
}

function Get-ImageInfo([string]$path) {
    $image = $null
    try {
        $image = [System.Drawing.Image]::FromFile($path)
        return @{ width = $image.Width; height = $image.Height }
    } finally {
        if ($image) { $image.Dispose() }
    }
}

function Get-CropRectangle([int]$width, [int]$height) {
    $scale = [Math]::Min([Math]::Floor($width / 16.0), [Math]::Floor($height / 9.0))
    if ($scale -lt 1) {
        throw "Image is too small to crop to 16:9: ${width}x${height}"
    }

    $cropWidth = [int]($scale * 16)
    $cropHeight = [int]($scale * 9)
    $cropX = [int][Math]::Floor(($width - $cropWidth) / 2)
    $cropY = [int][Math]::Floor(($height - $cropHeight) / 2)

    return New-Object System.Drawing.Rectangle -ArgumentList $cropX, $cropY, $cropWidth, $cropHeight
}

function New-CroppedThumbnailBytes([string]$thumbnailPath, [string]$extension) {
    $source = $null
    $target = $null
    $graphics = $null
    $stream = New-Object System.IO.MemoryStream

    try {
        $source = [System.Drawing.Image]::FromFile($thumbnailPath)
        $crop = Get-CropRectangle $source.Width $source.Height
        $target = New-Object System.Drawing.Bitmap -ArgumentList $crop.Width, $crop.Height
        $target.SetResolution($source.HorizontalResolution, $source.VerticalResolution)
        $graphics = [System.Drawing.Graphics]::FromImage($target)
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $targetRectangle = New-Object System.Drawing.Rectangle -ArgumentList 0, 0, $crop.Width, $crop.Height
        $graphics.DrawImage($source, $targetRectangle, $crop, [System.Drawing.GraphicsUnit]::Pixel)

        if ($extension -eq '.png') {
            $target.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
            $contentType = 'image/png'
        } else {
            $target.Save($stream, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            $contentType = 'image/jpeg'
        }

        return @{ bytes = $stream.ToArray(); contentType = $contentType; width = $crop.Width; height = $crop.Height }
    } finally {
        if ($graphics) { $graphics.Dispose() }
        if ($target) { $target.Dispose() }
        if ($source) { $source.Dispose() }
        $stream.Dispose()
    }
}

function Get-ThumbnailAudit() {
    $items = New-Object System.Collections.Generic.List[object]
    foreach ($entry in (Get-NewsIndexEntries)) {
        if ([string]::IsNullOrWhiteSpace($entry.thumbnail)) { continue }

        $item = @{
            title = $entry.title
            path = $entry.path
            thumbnail = $entry.thumbnail
            localThumbnail = $null
            width = 0
            height = 0
            ratio = 0
            targetRatio = [double]$targetThumbnailRatio
            cropWidth = 0
            cropHeight = 0
            issue = $null
            canCrop = $false
        }

        try {
            $resolved = Resolve-LocalThumbnailPath $entry.thumbnail
            $info = Get-ImageInfo $resolved.FullPath
            $crop = Get-CropRectangle $info.width $info.height
            $ratio = $info.width / [double]$info.height
            $isExact = ($info.width * 9) -eq ($info.height * 16)

            $item.localThumbnail = $resolved.RelativePath
            $item.width = $info.width
            $item.height = $info.height
            $item.ratio = [Math]::Round($ratio, 4)
            $item.cropWidth = $crop.Width
            $item.cropHeight = $crop.Height
            $item.canCrop = $true
            if (-not $isExact) { $item.issue = 'Thumbnail is not 16:9.' }
        } catch {
            $item.issue = $_.Exception.Message
        }

        if ($item.issue) { $items.Add($item) }
    }

    return @{ ok = $true; targetRatio = [double]$targetThumbnailRatio; items = $items.ToArray() }
}

function Send-ThumbnailCropPreview($res, [string]$thumbnail) {
    $resolved = Resolve-LocalThumbnailPath $thumbnail
    $extension = [System.IO.Path]::GetExtension($resolved.FullPath).ToLowerInvariant()
    $cropped = New-CroppedThumbnailBytes $resolved.FullPath $extension
    Send-Bytes $res 200 $cropped.contentType $cropped.bytes
}

function Apply-ThumbnailCrop($body) {
    $resolved = Resolve-LocalThumbnailPath ([string]$body.thumbnail)
    $extension = [System.IO.Path]::GetExtension($resolved.FullPath).ToLowerInvariant()
    $cropped = New-CroppedThumbnailBytes $resolved.FullPath $extension
    [System.IO.File]::WriteAllBytes($resolved.FullPath, $cropped.bytes)

    return @{
        ok = $true
        thumbnail = [string]$body.thumbnail
        localThumbnail = $resolved.RelativePath
        width = $cropped.width
        height = $cropped.height
    }
}

function Resolve-PythonExecutable() {
    # Returns [string[]]: [exe, optional_arg1, ...]. Always wrap with the comma
    # operator so single-element arrays don't get unwrapped to a bare string by
    # the caller (`$python[0]` would then index the first character).

    if ($env:ADVR_PYTHON) {
        if (Test-Path -LiteralPath $env:ADVR_PYTHON -PathType Leaf) {
            return ,@([string]$env:ADVR_PYTHON)
        }
        throw "ADVR_PYTHON points to a missing file: $($env:ADVR_PYTHON)"
    }

    foreach ($candidate in @('python.exe', 'python3.exe', 'py.exe', 'python', 'python3', 'py')) {
        $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($cmd -and $cmd.Source -and (Test-Path -LiteralPath $cmd.Source -PathType Leaf)) {
            # Only the py.exe launcher accepts the -3 selector; python.exe doesn't.
            $leaf = [System.IO.Path]::GetFileNameWithoutExtension($cmd.Source).ToLowerInvariant()
            if ($leaf -eq 'py') { return ,@([string]$cmd.Source, '-3') }
            return ,@([string]$cmd.Source)
        }
    }
    throw 'Python is required to create posts but was not found on PATH. Install Python 3 (https://www.python.org/) and make sure "python" or "py" works in a new PowerShell window. You can also point ADVR_PYTHON at a python.exe.'
}

function New-NewsPost($body) {
    if (-not (Test-Path -LiteralPath $createNewsPostScript -PathType Leaf)) {
        throw "create_news_post.py not found at: $createNewsPostScript. Set the ADVR_CREATE_NEWS_POST env var to its full path."
    }

    $title = ([string]$body.title).Trim()
    $date = ([string]$body.date).Trim()
    $markdown = [string]$body.markdown
    if ([string]::IsNullOrWhiteSpace($title))    { throw 'Title is required.' }
    if ([string]::IsNullOrWhiteSpace($date))     { throw 'Date is required.' }
    if ([string]::IsNullOrWhiteSpace($markdown)) { throw 'Markdown body is required.' }

    $description = ([string]$body.description).Trim()
    $slug        = ([string]$body.slug).Trim()
    $thumbnailFileName = ([string]$body.thumbnailFileName).Trim()
    $force       = [bool]$body.force

    # Stage everything (markdown + uploaded images) in a temp folder so the
    # python script's relative-path image resolver finds them.
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('advr_newpost_' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    $thumbnailPath = $null

    try {
        $markdownPath = Join-Path $tempDir 'post.md'
        [System.IO.File]::WriteAllText($markdownPath, $markdown, $utf8NoBom)

        if ($body.images) {
            foreach ($image in $body.images) {
                $name = Get-SafeFileName ([string]$image.name)
                $data = [string]$image.dataBase64
                $data = $data -replace '^data:.*?;base64,', ''
                $bytes = [System.Convert]::FromBase64String($data)
                $target = Join-Path $tempDir $name
                [System.IO.File]::WriteAllBytes($target, $bytes)
                if ($thumbnailFileName -and $name -eq (Get-SafeFileName $thumbnailFileName)) {
                    $thumbnailPath = $target
                }
            }
        }

        $python = Resolve-PythonExecutable
        $pyArgs = New-Object System.Collections.Generic.List[string]
        foreach ($p in $python | Select-Object -Skip 1) { $pyArgs.Add($p) }
        $pyArgs.Add((Resolve-Path -LiteralPath $createNewsPostScript).Path)
        $pyArgs.Add($markdownPath)
        $pyArgs.Add('--title');       $pyArgs.Add($title)
        $pyArgs.Add('--date');        $pyArgs.Add($date)
        if ($description)       { $pyArgs.Add('--description'); $pyArgs.Add($description) }
        if ($slug)              { $pyArgs.Add('--slug');        $pyArgs.Add($slug) }
        if ($thumbnailPath)     { $pyArgs.Add('--thumbnail');   $pyArgs.Add($thumbnailPath) }
        if ($force)             { $pyArgs.Add('--force') }

        # Build a properly-quoted command line manually. We use System.Diagnostics.Process
        # rather than Start-Process so spaces in arguments survive (Start-Process
        # silently breaks on those) and so we get a clean Win32Exception with the
        # actual exe path on failure.
        function Quote-Arg([string]$a) {
            if ($a -eq '' -or $a -match '[\s"]') {
                # Escape backslashes preceding a quote, then escape quotes.
                $escaped = $a -replace '(\\*)"','$1$1\"'
                $escaped = $escaped -replace '(\\+)$','$1$1'
                return '"' + $escaped + '"'
            }
            return $a
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $python[0]
        $psi.Arguments = ($pyArgs | ForEach-Object { Quote-Arg $_ }) -join ' '
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.CreateNoWindow = $true
        $psi.WorkingDirectory = $tempDir

        Write-Host ("[create-post] running: {0} {1}" -f $psi.FileName, $psi.Arguments) -ForegroundColor DarkCyan

        $proc = $null
        try {
            $proc = [System.Diagnostics.Process]::Start($psi)
        } catch [System.ComponentModel.Win32Exception] {
            throw "Failed to launch Python at '$($psi.FileName)': $($_.Exception.Message). If this path is wrong, set the ADVR_PYTHON env var to your python.exe."
        }

        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        if ($proc.ExitCode -ne 0) {
            $msg = $stderr
            if ([string]::IsNullOrWhiteSpace($msg)) { $msg = $stdout }
            if ([string]::IsNullOrWhiteSpace($msg)) { $msg = "create_news_post.py exited with code $($proc.ExitCode)." }
            throw $msg.Trim()
        }

        # Find the entry we just inserted (always at the top of news.txt) so the
        # frontend can highlight it without re-parsing on its own.
        $entries = Get-NewsIndexEntries
        $newEntry = $null
        foreach ($entry in $entries) {
            if ($entry.title -eq $title -and $entry.date -eq $date) {
                $newEntry = $entry
                break
            }
        }

        return @{ ok = $true; entry = $newEntry; log = $stdout.Trim() }
    } finally {
        try { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }
}

function Handle-ApiRequest($req, $res) {
    $path = $req.Url.AbsolutePath.TrimEnd('/')
    if ($path -eq '') { $path = '/' }

    if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/assets') {
        Send-Json $res 200 (Get-ArticleAssets $req.QueryString['path'])
        return
    }

    if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/thumbnail-audit') {
        Send-Json $res 200 (Get-ThumbnailAudit)
        return
    }

    if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/thumbnail-crop-preview') {
        Send-ThumbnailCropPreview $res $req.QueryString['thumbnail']
        return
    }

    if ($req.HttpMethod -eq 'GET' -and $path -eq '/api/status') {
        Send-Json $res 200 @{ ok = $true; root = $root }
        return
    }

    if ($req.HttpMethod -ne 'POST') {
        Send-Json $res 405 @{ ok = $false; error = 'Method not allowed.' }
        return
    }

    $body = Read-JsonBody $req
    switch ($path) {
        '/api/save-entry' { Send-Json $res 200 (Save-NewsEntry $body); return }
        '/api/remove-entry' { Send-Json $res 200 (Remove-NewsEntry $body); return }
        '/api/crop-thumbnail' { Send-Json $res 200 (Apply-ThumbnailCrop $body); return }
        '/api/create-post' { Send-Json $res 200 (New-NewsPost $body); return }
        default { Send-Json $res 404 @{ ok = $false; error = 'Unknown API endpoint.' }; return }
    }
}

$listener = $null
for ($candidatePort = $startPort; $candidatePort -lt ($startPort + 20); $candidatePort++) {
    $candidatePrefix = "http://localhost:$candidatePort/"
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($candidatePrefix)
    try {
        $listener.Start()
        $port = $candidatePort
        $prefix = $candidatePrefix
        break
    } catch {
        $listener.Close()
        $listener = $null
        if ($candidatePort -eq ($startPort + 19)) {
            Write-Host "Failed to bind a preview server port in range $startPort-$($startPort + 19)." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
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

        if ($req.Url.AbsolutePath.StartsWith('/api/', [System.StringComparison]::OrdinalIgnoreCase)) {
            try {
                Handle-ApiRequest $req $res
            } catch {
                Send-Json $res 500 @{ ok = $false; error = $_.Exception.Message }
            }
            continue
        }

        $relPath = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath.TrimStart('/'))
        if ([string]::IsNullOrEmpty($relPath)) { $relPath = 'news_preview.html' }

        $fullPath = Join-Path $root $relPath
        $resolved = $null
        try { $resolved = (Resolve-Path -LiteralPath $fullPath -ErrorAction Stop).Path } catch {}

        if (-not $resolved -or -not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            Send-Text $res 404 'text/plain; charset=utf-8' "404 Not Found: $relPath"
            continue
        }

        $ext = [System.IO.Path]::GetExtension($resolved).ToLowerInvariant()
        $contentType = $mime[$ext]
        if (-not $contentType) { $contentType = 'application/octet-stream' }

        try {
            $bytes = [System.IO.File]::ReadAllBytes($resolved)
            Send-Bytes $res 200 $contentType $bytes
        } catch {
            Send-Text $res 500 'text/plain; charset=utf-8' "500: $($_.Exception.Message)"
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
