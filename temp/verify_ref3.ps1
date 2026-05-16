$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open("C:\Users\budi.kusharyanto\OneDrive\WS Dokumen\Proposal JHL Group-Innovis ref 3.docx")
$text = $doc.Content.Text
$doc.Close($false)
$word.Quit()
Write-Output $text.Substring(0, [Math]::Min(4000, $text.Length))