$word = New-Object -ComObject Word.Application
$word.Visible = $false

# Get formatting from SIPEDANG template
$template = $word.Documents.Open("C:\Users\budi.kusharyanto\OneDrive\WS Dokumen\Proposal Pengembangan OJK SIPEDANG 2026 (ref 1).docx")
$templateStyles = @()
foreach ($style in $template.Styles) {
    if ($style.NameLocal -match "Heading|Title|Quote") {
        $templateStyles += [PSCustomObject]@{
            Name = $style.NameLocal
            FontName = $style.Font.Name
            FontSize = $style.Font.Size
            Bold = $style.Font.Bold
            Color = $style.Font.Color
        }
    }
}
$template.Close($false)

# Get content from rev1.docx
$rev1 = $word.Documents.Open("C:\Users\budi.kusharyanto\OneDrive\WS Dokumen\Proposal JHL Group rev1.docx")
$rev1Content = $rev1.Content
$rev1.Close($false)

$word.Quit()

Write-Output "=== Template Styles ==="
$templateStyles | Format-Table -AutoSize
Write-Output "=== Content Length ==="
Write-Output $rev1Content.Text.Length