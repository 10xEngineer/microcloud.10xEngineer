Function download(url, targetLocation)
  Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
  objXMLHTTP.open "GET", url, false
  objXMLHTTP.send()

  If objXMLHTTP.Status = 200 Then
    Set objADOStream = CreateObject("ADODB.Stream")
    objADOStream.Open
    objADOStream.Type = 1 'adTypeBinary
    objADOStream.Write objXMLHTTP.ResponseBody
    objADOStream.Position = 0 

    Set objFSO = Createobject("Scripting.FileSystemObject")
    If objFSO.Fileexists(targetLocation) Then
      objFSO.DeleteFile targetLocation
    End if
    Set objFSO = Nothing

    objADOStream.SaveToFile targetLocation
    objADOStream.Close
    Set objADOStream = Nothing
  End if

  Set objXMLHTTP = Nothing
End Function

Dim source 
source = "http://rubyforge.org/frs/download.php/76054/rubyinstaller-1.9.3-p194.exe"
Dim target = "C:\ruby-installer.exe"

download(source, target)
