$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open("C:\Users\budi.kusharyanto\OneDrive\WS Dokumen\Proposal Pengembangan OJK SIPEDANG 2026 (ref 1).docx")
$text = $doc.Content.Text
$doc.Close($false)
$word.Quit()
Write-Output $text.Substring(0, [Math]::Min(8000, $text.Length))